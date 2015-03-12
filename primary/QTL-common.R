library(data.table)
library(parallel)
library(MatrixEQTL)

covariates.file <- "../data/patients.tsv"
snpspos.file <- "../data/snp.txt"
snp.files <- function(chr) {
    ptn <- "../data/transposed_1kG/chr%d/chr%d.*.trans.txt"
    Sys.glob(sprintf(ptn, chr, chr))
}
ncpus <- 2
n.pcs <- 20

rm.pcs <- function (data, n.pcs) {
    data <- t(data)
    s <- svd(data)
    s$d[(n.pcs+1):length(s$d)] <- 0 
    res <- data - s$u %*% diag(s$d) %*% t(s$v)
    res <- apply(res, 2, scale.rank)
    dimnames(res) <- dimnames(data)
    t(res)
}

read.cvrt <- function () {
    id.vars <- c("projid", "acetylation.id", "methylation.id", "expression.id", "genotype.id")
    cov.vars <- c("msex", "age_death", "pmi", "EV1", "EV2", "EV3")
    cvrt <- fread(covariates.file, select=c(id.vars, cov.vars))
    setkey(cvrt, projid)
    na.omit(cvrt)
}

cvrt2sd <- function (cvrt) {
    id.vars <- c("projid", "acetylation.id", "methylation.id", "expression.id", "genotype.id")
    projid <- cvrt[,projid]
    vars <- setdiff(colnames(cvrt), id.vars)
    sd <- t(cvrt[,vars, with=FALSE])
    dimnames(sd) <- list(vars, projid)
    SlicedData$new()$CreateFromMatrix(sd)
}

scale.rank <- function (x) scale(rank(x))

read.snpspos <- function () {
    snpspos <- fread(snpspos.file, drop=3)
    setnames(snpspos, colnames(snpspos), c("snp.chr", "snp.pos", "snp"))
    snpspos[,snp.chr := as.integer(sub("chr", "", snp.chr))]
    snpspos[,snp := as.integer(sub("rs", "", snp))]
    setcolorder(snpspos, c("snp", "snp.chr", "snp.pos"))
    setkey(snpspos, snp)
}

read.snps <- function (snp.file, snpspos, cvrt) {
    # get SNP IDs from file
    snp.ids <- strsplit(readLines(snp.file, n=1), " ")[[1]]
    snp.ids <- ifelse(grepl("rs", snp.ids), gsub("rs", "", snp.ids), NA)

    # find column indices for needed SNPs
    keep.cols <- snpspos[,1+which(snp.ids %in% snp)]
    stopifnot(order(keep.cols) == 1:length(keep.cols))
    if (length(keep.cols) == 0) return (NULL)

    # read SNP values
    snps <- fread(snp.file, select=c(1, keep.cols))

    # subset patients
    setnames(snps, "V1", "projid")
    setnames(snps, paste0("V", keep.cols), snp.ids[keep.cols-1])
    snps[,projid := as.integer(gsub("[A-Z]", "", projid))]
    setkey(snps, projid)
    snps <- snps[cvrt[,"projid",with=FALSE]]

    # at this point the dimensions should be right
    #stopifnot(snps[,projid] == cvrt[,projid])
    #stopifnot(tail(colnames(snps), -1) == snp.ids[keep.cols-1])

    # make a SlicedData object
    snps <- t(apply(snps[,projid := NULL], 2, scale.rank))
    dimnames(snps) <- list(snp.ids[keep.cols-1], cvrt[,projid])
    SlicedData$new()$CreateFromMatrix(snps)
}

# run Matrix eqTL
do.matrix.eqtl <- function (snps, gene, genepos, snpspos, cvrt=SlicedData$new()) {

    outfile <- tempfile()
    Matrix_eQTL_main(
        snps = snps, 
        gene = gene, 
        cvrt = cvrt,
        output_file_name = "/dev/null",
        pvOutputThreshold = 0,
        useModel = modelLINEAR,
        errorCovariance = numeric(), 
        verbose = FALSE, 
        output_file_name.cis = outfile,
        pvOutputThreshold.cis = 1,
        snpspos = snpspos, 
        genepos = genepos,
        cisDist = 100000,
        pvalue.hist = FALSE,
        min.pv.by.genesnp = FALSE,
        noFDRsaveMemory = TRUE)
    
    # because we scaled the data to have SD=1, beta = rho
    # (ie. regression slope = correlation coefficient)
    old.names <- c("SNP", "gene", "beta", "p-value", "t-stat")
    new.names <- c("snp", "feature", "rho", "p.value", "t.stat")
    res <- setnames(fread(outfile), old.names, new.names)
    unlink(outfile)
    setkey(res, snp, feature)
}

get.all.qtls <- function (gene, genepos, cvrt, outdir) {

    snpspos <- read.snpspos()
    cvrt.sd <- cvrt2sd(cvrt)

    mclapply(15:1, function (chr) {

        cur.snpspos <- snpspos[snp.chr == chr]
        cur.genepos <- genepos[feature.chr == chr]

        # get only features in the current chromosome
        cur.gene <- merge(gene, cur.genepos[, "feature", with=FALSE])

        stopifnot(all(cur.gene[,feature] %in% cur.genepos[,feature]))
        stopifnot(tail(colnames(cur.gene), -1) == cvrt[,projid])

        # make a SlicedData for the current features
        feature <- cur.gene[,feature]
        cur.gene <- as.matrix(cur.gene[,feature := NULL])
        dimnames(cur.gene) <- list(feature, cvrt[,projid])

        cur.gene.sd <- t(apply(cur.gene, 1, scale.rank))
        stopifnot(all(apply(cur.gene.sd, 1, function (x) isTRUE(all.equal(sd(x), 1)))))
        dimnames(cur.gene.sd) <- dimnames(cur.gene)
        cur.gene.sd <- SlicedData$new()$CreateFromMatrix(cur.gene.sd)

        stopifnot(colnames(cur.gene.sd) == colnames(cvrt.sd))
    
        setDF(cur.genepos)
        # the genotype data is spread over multiple files
        eqtls <- Reduce(function (x, snp.file) {
            cat(snp.file, "\n")
            snps <- read.snps(snp.file, cur.snpspos, cvrt)
            stopifnot(colnames(snps) == colnames(cvrt.sd))

            setDF(cur.snpspos)
            
            vcols <- c("rho", "p.value", "t.stat")
            res.cov <- do.matrix.eqtl(snps, cur.gene.sd, cur.genepos, cur.snpspos, cvrt.sd)
            res.nocov <- do.matrix.eqtl(snps, cur.gene.sd, cur.genepos, cur.snpspos)
            setnames(res.nocov, vcols, paste0(vcols, ".nocov"))

            res <- lapply(1:n.pcs, function (i) {
                cur.gene.pc <- rm.pcs(cur.gene, i)
                stopifnot(all(apply(cur.gene.pc, 1, function (x) isTRUE(all.equal(sd(x), 1)))))
                stopifnot(rownames(cur.gene.pc) == feature)
                stopifnot(colnames(cur.gene.pc) == cvrt[,projid])

                cur.gene.pc <- SlicedData$new()$CreateFromMatrix(cur.gene.pc)
                res <- do.matrix.eqtl(snps, cur.gene.pc, cur.genepos, cur.snpspos, cvrt.sd)
                setnames(res, vcols, paste0(vcols, ".PC", i))
            })
            setDT(cur.snpspos)

            res[[n.pcs+1]] <- res.cov
            res[[n.pcs+2]] <- res.nocov
            res <- Reduce(merge, res)
            stopifnot(nrow(res) == nrow(res.cov))
            rbind(x, res)
        }, snp.files(chr), init=NULL) # Reduce
        
        # to make it easier later, record the gene name, TSS position, and SNP position in the output
        eqtls <- merge(setkey(eqtls, feature), genepos)
        eqtls <- merge(setkey(eqtls, snp), snpspos)
        eqtls[,feature.pos.2 := NULL]
        write.table(eqtls, sprintf("%s/chr%d.tsv", outdir, chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
    }, mc.cores=ncpus) # Reduce
}
