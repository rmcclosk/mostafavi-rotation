# This file contains functions common to all QTL analyses.

library(data.table)
library(parallel)
library(MatrixEQTL)

source(file=file.path("utils", "load_data.R"))
source(file=file.path("utils", "misc.R"))

# run Matrix eQTL
do.matrix.eqtl <- function (snps, gene, genepos, snpspos, outfile, cvrt=NULL) {

    # make sure everything matches up
    if ("snp" %in% colnames(snpspos))
        stopifnot(all(rownames(snps) %in% snpspos$snp))
    else
        stopifnot(all(rownames(snps) %in% snpspos$feature))
    stopifnot(colnames(snps) == colnames(gene))
    stopifnot(rownames(gene) == genepos$feature)

    if (is.null(cvrt)) {
        cvrt <- SlicedData$new()
    } else {
        stopifnot(colnames(cvrt) == colnames(gene))
    }

    tfile <- tempfile()
    Matrix_eQTL_main(
        snps = snps, 
        gene = gene, 
        cvrt = cvrt,
        output_file_name = "/dev/null",
        pvOutputThreshold = 0,
        useModel = modelLINEAR,
        errorCovariance = numeric(), 
        verbose = FALSE, 
        output_file_name.cis = tfile,
        pvOutputThreshold.cis = 1,
        snpspos = snpspos, 
        genepos = genepos,
        cisDist = 100000,
        pvalue.hist = FALSE,
        min.pv.by.genesnp = FALSE,
        noFDRsaveMemory = TRUE)
    
    write.table(fread(tfile), outfile, append=TRUE, row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
    unlink(tfile)
}

# run Matrix eQTL on all chromosomes
get.all.qtls.h <- function (gene, genepos, snpspos, manifest, outfile, cvrt=SlicedData$new(), ncpus=1) {

    if (file.exists (outfile)) {
        cat(sprintf("Not recreating %s\n", outfile), file=stderr())
        return(NULL)
    } else {
        cat(sprintf("Creating %s\n", outfile), file=stderr())
    }

    # write header to the output file
    # because we scaled the data to have SD=1, beta = rho
    # (ie. regression slope = correlation coefficient)
    cat("snp\tfeature\trho\tt.stat\tp.value\n", file=outfile)

    chunk.size <- 10000
    mclapply(1:22, function (cur.chr) {
        cat(sprintf("Chromosome %d\n", cur.chr), file=stderr())

        # find genes in the current chromosome
        gene.idx <- genepos[,which(chr == cur.chr)]

        # subset the gene data
        cur.gene <- t(scale.rank(gene[,gene.idx]))
        stopifnot(all(sapply(apply(cur.gene, 1, sd), all.equal, 1)))
        stopifnot(all(sapply(apply(cur.gene, 1, mean), all.equal, 0)))
        cur.gene <- SlicedData$new()$CreateFromMatrix(cur.gene)
        cur.genepos <- genepos[gene.idx,]

        # filter for SNPs within 100kb of a feature
        cur.snpspos <- snpspos[chr == cur.chr]
        cur.snpspos <- cur.snpspos[min.dist(cur.genepos[,pos], cur.snpspos[,pos]) <= 100000]
        setkey(cur.snpspos, snp)

        cur.manifest <- merge(manifest, cur.snpspos[, "snp", with=FALSE])

        setDF(cur.snpspos)
        setDF(cur.genepos)

        chunks <- rep(1:(nrow(cur.manifest)/chunk.size+1), each=chunk.size)[1:nrow(cur.manifest)]
        by(cur.manifest, chunks, function (x) {
            snps <- t(scale.rank(load.gdata(x, patients)))
            stopifnot(all(sapply(apply(snps, 1, sd), all.equal, 1)))
            stopifnot(all(sapply(apply(snps, 1, mean), all.equal, 0)))
            snps <- SlicedData$new()$CreateFromMatrix(snps)
            do.matrix.eqtl(snps, cur.gene, cur.genepos, cur.snpspos, outfile, cvrt)
            rm(snps)
            gc()
        })
        rm(cur.gene)
        gc()
    }, mc.cores=ncpus)
    cat(sprintf("Done creating %s\n", outfile), file=stderr())
} 

# this is the main function to do the QTL analyses
# refer to the Matrix eQTL documentation
get.all.qtls <- function (gene, genepos, patients, outdir, ncpus=1) {

    # take only variables of interest for covariates
    cvrt.vars <- c("msex", "age_death", "pmi", "EV1", "EV2", "EV3")
    cvrt <- patients[,c("projid", cvrt.vars), with=FALSE]
    projid <- cvrt[,projid]
    cvrt <- t(cvrt[,projid := NULL])
    colnames(cvrt) <- projid
    cvrt <- SlicedData$new()$CreateFromMatrix(cvrt)

    # load SNP positions and genotype manifest
    snpspos <- load.snps()
    manifest <- load.manifest()

    setkey(manifest, snp)
    setkey(snpspos, snp)
    manifest <- merge(manifest, snpspos[,"snp", with=FALSE])

    outfile <- file.path(outdir, "PC0.nocov.tsv")
    if (!file.exists(outfile)) {
        get.all.qtls.h(gene, genepos, snpspos, manifest, outfile, cvrt=SlicedData$new(), ncpus=ncpus)
    } else {
        cat("Not recreating", outfile, "\n", file=stderr())
    }

    gene.svd <- svd(gene)
    for (pc.rm in 0:20) {
        gene <- rm.pcs.3(gene, gene.svd, pc.rm)
        outfile <- file.path(outdir, paste0("PC", pc.rm, ".tsv"))
        get.all.qtls.h(gene, genepos, snpspos, manifest, outfile, cvrt, ncpus)
    }
}

# like get.all.qtls, but it accepts two data sets instead of 1, and compares
# them to each other rather than to the SNPs
get.all.pairs <- function (data1, data1pos, data2, data2pos, pc.rm, cvrt, outfile) {
    # add second position column
    data2pos$pos2 <- data2pos$pos

    # match positions to data
    data1pos <- data1pos[na.omit(match(colnames(data1), feature)),]
    data2pos <- data2pos[na.omit(match(colnames(data2), feature)),]

    data1 <- data1[,na.omit(match(data1pos[,feature], colnames(data1)))]
    data2 <- data2[,na.omit(match(data2pos[,feature], colnames(data2)))]

    # match patient IDs to data
    data1 <- data1[na.omit(match(colnames(cvrt), rownames(data1))),]
    data2 <- data2[na.omit(match(colnames(cvrt), rownames(data2))),]

    # remove principal components
    data1 <- t(scale.rank(rm.pcs(data1, pc.rm[1])))
    data2 <- t(scale.rank(rm.pcs(data2, pc.rm[2])))

    idx1 <- which(min.dist(data2pos[,pos], data1pos[,pos]) <= 100000)
    idx2 <- which(min.dist(data1pos[,pos], data2pos[,pos]) <= 100000)

    data1pos <- data1pos[idx1,]
    data2pos <- data2pos[idx2,]
    data1 <- data1[idx1,]
    data2 <- data2[idx2,]

    data1 <- SlicedData$new()$CreateFromMatrix(data1)
    data2 <- SlicedData$new()$CreateFromMatrix(data2)
    data1$ResliceCombined(sliceSize = 1000L)
    data2$ResliceCombined(sliceSize = 1000L)
    
    # make sure everything matches
    stopifnot(colnames(data1) == colnames(cvrt))
    stopifnot(colnames(data2) == colnames(cvrt))
    stopifnot(rownames(data1) == data1pos[,as.character(feature)])
    stopifnot(rownames(data2) == data2pos[,as.character(feature)])

    setDF(data1pos)
    setDF(data2pos)
    do.matrix.eqtl(data1, data2, data2pos, data1pos, outfile, cvrt)
}
