#!/usr/bin/env Rscript

library(qvalue)
library(data.table)
library(MatrixEQTL)

source(file="liftover.R")

make.sliced.data <- function (data) {
    data <- t(apply(data, 1, rank, ties.method="average"))
    SlicedData$new()$CreateFromMatrix(data)
}

cis.outfile = tempfile()
trans.outfile = tempfile()

# read expression data and get common patient IDs
gene <- fread("residual_gene_expression_expressed_genes_2FPKM100ind.txt")
gene[,V1 := as.integer(gsub(":.*", "", V1))]

snp.id <- readLines("transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt", n=1)
snp.id <- strsplit(snp.id, " ")[[1]]
classes <- c("character", rep("NULL", length(snp.id)))
snps <- fread("transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt", colClasses=classes)
snps[,V1 := as.integer(gsub("[A-Z]", "", V1))]

setkey(gene, V1)
setkey(snps, V1)
patient.id <- merge(snps[,"V1", with=FALSE], gene[,"V1", with=FALSE])
gene <- unique(gene)[patient.id,][,V1 := NULL]

gene.id <- sub(".*ENSG", "", colnames(gene))
gene.id <- as.integer(sapply(strsplit(gene.id, ".", fixed=TRUE), "[[", 1))
gene <- t(as.matrix(gene))
dimnames(gene) <- list(gene.id, patient.id[,V1])
gene <- make.sliced.data(gene)

# get gene locations
gene.id <- setkey(data.table(geneid=gene.id), geneid)

genepos <- fread("ensemblGenes.tsv")
genepos[,V4 := ifelse(V6, V4, V5)]
genepos[,c("V2", "V5", "V6") := NULL]
setnames(genepos, c("V1", "V3", "V4"), c("geneid", "chr", "s1"))
genepos[,s2 := s1]
setkey(genepos, geneid)

genepos <- setDF(merge(genepos, gene.id))

get.snpspos <- function (snp.file, rsid) {
    # read SNP positions
    snpspos <- readLines(snp.file, n=1)
    snpspos <- data.table(snp=strsplit(snpspos, " ")[[1]])
    snpspos[,id := 1:nrow(snpspos)]
    
    # lift over SNPs in chrN:POS format
    chrpos <- snpspos[grepl("chr", snp)]
    if (nrow(chrpos) > 0) {
        chrpos[,c("chr", "pos") := as.list(as.integer(strsplit(sub("chr", "", snp), ":")[[1]])), by=snp]
        chrpos[,c("chr", "pos") := liftover(chr, pos, snp)[,c("chr", "pos"),with=FALSE]]
        chrpos[,snp := NULL]
    }
    
    # get positions for SNPs with RSIDs
    rs <- snpspos[grepl("rs", snp),]
    rs[,snp := as.integer(sub("rs", "", snp))]
    rs[,c("chr", "pos") := rsid[rs, c("chr", "pos"), with=FALSE]]
    rs[,snp := NULL]
    
    # combine both sets of positions
    if (nrow(chrpos) > 0)
        chrpos <- setkey(rbind(rs, chrpos), id)
    else
        chrpos <- setkey(rs, id)
    setkey(snpspos, id)
    snpspos <- setcolorder(chrpos[snpspos][,id := NULL], c("snp", "chr", "pos"))
    snpspos[, snp := pos]
}

sink("/dev/null")
sapply(1:22, function (chr) {
    if (file.exists(sprintf("eQTL/chr%d.tsv", chr))) return()

    # read RSIDs
    rsid <- fread(sprintf("SNPChrPosOnRef/chr%s.bcp", chr))
    setnames(rsid, c("V1", "V2", "V3"), c("snp", "chr", "pos"))
    setkey(rsid, snp)
    
    snp.files <- Sys.glob(sprintf("transposed_1kG/chr%d/chr%d.*.trans.txt", chr, chr))
    
    eqtls <- Reduce(function (x, snp.file) {
        snpspos <- get.snpspos(snp.file, rsid)
        classes <- c("character", snpspos[,ifelse(is.na(chr) | is.na(pos), "NULL", "numeric")])
        snpspos <- snpspos[!is.na(chr) & !is.na(pos),]
        
        # read SNP values
        print(snp.file)
        snps <- fread(snp.file, colClasses=classes)
        snps[,V1 := as.integer(gsub("[A-Z]", "", V1))]
        setkey(snps, V1)
        snps <- unique(snps)[patient.id,][,V1 := NULL]
        
        snps <- t(as.matrix(snps))
        dimnames(snps) <- list(snpspos[,snp], patient.id[,V1])
        snps <- make.sliced.data(snps)
        setDF(snpspos)
        
        # run Matrix eqTL
        Matrix_eQTL_main(
            snps = snps, 
            gene = gene, 
            cvrt = SlicedData$new(),
            output_file_name = trans.outfile,
            pvOutputThreshold = 0,
            useModel = modelLINEAR,
            errorCovariance = numeric(), 
            verbose = FALSE, 
            output_file_name.cis = cis.outfile,
            pvOutputThreshold.cis = 1,
            snpspos = snpspos, 
            genepos = genepos,
            cisDist = 1000000,
            pvalue.hist = FALSE,
            min.pv.by.genesnp = FALSE,
            noFDRsaveMemory = TRUE)
        
        res <- fread(cis.outfile)
        setnames(res, c("SNP", "beta", "p-value"), c("position", "rho", "p.value"))
        res[,"t-stat" := NULL, with=FALSE]
    
        rbind(x, res)
    }, snp.files, init=NULL) # Reduce
    
    eqtls[,adj.p.value := p.adjust(p.value, method="holm"), gene]
    eqtls[,p.value := NULL]
    eqtls <- eqtls[,.SD[which.min(adj.p.value),],by=gene]
    write.table(eqtls, sprintf("eQTL/chr%d.tsv", chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
}) # Reduce
sink()

unlink(cis.outfile)
unlink(trans.outfile)
