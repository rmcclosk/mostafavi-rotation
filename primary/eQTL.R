#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)
library(MatrixEQTL)

source(file="../utils/liftover.R")

gene.file <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
snp.file <- "../data/transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt"
genepos.file <- "../data/ensemblGenes.tsv"
snpspos.file <- "../data/snp.txt"

scale.rank <- function (x) scale(rank(x))

make.sliced.data <- function (data) {
    data <- t(apply(data, 1, scale.rank))
    SlicedData$new()$CreateFromMatrix(data)
}

## read gene positions
genepos <- fread(genepos.file, drop=2)
setnames(genepos, colnames(genepos), c("feature", "feature.chr", "start", "end", "fwd"))
genepos[,feature.pos := ifelse(fwd, start, end)]
genepos[,c("start", "end", "fwd") := NULL]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))

# read SNP positions
snpspos <- fread(snpspos.file, drop=3)
setnames(snpspos, colnames(snpspos), c("snp.chr", "snp.pos", "snp"))
snpspos[,snp.chr := as.integer(sub("chr", "", snp.chr))]
snpspos[,snp := as.integer(sub("rs", "", snp))]
setcolorder(snpspos, c("snp", "snp.chr", "snp.pos"))
setkey(snpspos, snp)

# read expression data
gene <- fread(gene.file)
setnames(gene, "V1", "patient.id")
gene[,patient.id := as.integer(gsub(":.*", "", patient.id))]
setkey(gene, patient.id)
gene <- unique(gene)
gene.id <- gsub(".*:ENSG0+|[.][0-9]+", "", colnames(gene)[2:ncol(gene)])
setnames(gene, colnames(gene)[2:ncol(gene)], gene.id)

# read patient IDs for genotype data
patient <- fread(snp.file, select=1)
setnames(patient, "V1", "patient.id")
patient[,patient.id := as.integer(gsub("[A-Z]", "", patient.id))]
setkey(patient, patient.id)

# get patient IDs common to both data types
patient <- merge(gene[,"patient.id", with=FALSE], patient)

# restrict expression data to common patients
gene <- gene[patient,]
gene[,patient.id := NULL]

# make expression data into a SlicedData object
gene <- gene[,lapply(.SD, scale.rank)]
gene <- t(as.matrix(gene))
colnames(gene) <- patient[,patient.id]
gene <- SlicedData$new()$CreateFromMatrix(gene)

cis.outfile = tempfile()
sapply(22:1, function (chr) {

    # the genotype data is spread over multiple files
    snp.files <- Sys.glob(sprintf("../data/transposed_1kG/chr%d/chr%d.*.trans.txt", chr, chr))
    
    setDF(genepos)
    eqtls <- Reduce(function (x, snp.file) {
        print(snp.file)
        
        # get SNP IDs from file
        snp.ids <- strsplit(readLines(snp.file, n=1), " ")[[1]]
        snp.ids <- as.integer(ifelse(grepl("rs", snp.ids), gsub("rs", "", snp.ids), NA))
        cur.snpspos <- snpspos[snp.ids,]
        keeps <- cur.snpspos[,which(!is.na(snp.chr))]
        cur.snpspos <- cur.snpspos[keeps,]
        
        # read SNP values, and reduce to common patients
        snps <- fread(snp.file, select=c(1, 1+keeps))
        setnames(snps, "V1", "patient.id")
        snps[,patient.id := as.integer(gsub("[A-Z]", "", patient.id))]
        setkey(snps, patient.id)
        snps <- unique(snps)[patient,][,patient.id := NULL]
        
        # make a SlicedData object
        snps <- snps[,lapply(.SD, scale.rank)]
        snps <- t(as.matrix(snps))
        dimnames(snps) <- list(cur.snpspos[,snp], patient[,patient.id])
        snps <- SlicedData$new()$CreateFromMatrix(snps)
        cat("foo\n")

        setDF(cur.snpspos)
        # run Matrix eqTL
        Matrix_eQTL_main(
            snps = snps, 
            gene = gene, 
            cvrt = SlicedData$new(),
            output_file_name = "/dev/null",
            pvOutputThreshold = 0,
            useModel = modelLINEAR,
            errorCovariance = numeric(), 
            verbose = FALSE, 
            output_file_name.cis = cis.outfile,
            pvOutputThreshold.cis = 1,
            snpspos = cur.snpspos, 
            genepos = genepos,
            cisDist = 1000000,
            pvalue.hist = FALSE,
            min.pv.by.genesnp = FALSE,
            noFDRsaveMemory = TRUE)
        
        res <- fread(cis.outfile)
        setnames(res, c("SNP", "gene"), c("snp", "feature"))
        cat("foo\n")
        res[,"t-stat" := NULL, with=FALSE]
        rbind(x, res)
    }, snp.files, init=NULL) # Reduce
    setDT(genepos)
    
    # because we scaled the data to have SD=1, beta = rho
    # (ie. regression slope = correlation coefficient)
    setnames(eqtls, "beta", "rho")

    # to make it easier later, record the gene name, TSS position, and SNP position in the output
    setkey(eqtls, feature)
    eqtls <- merge(eqtls, genepos)
    setkey(eqtls, snp)
    eqtls <- merge(eqtls, snpspos)
    eqtls[,feature.pos.2 := NULL]
    write.table(eqtls, sprintf("eQTL/chr%d.tsv", chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
}) # Reduce

unlink(cis.outfile)
