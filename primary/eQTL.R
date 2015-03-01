#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

gene.file <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
snp.file <- "../data/transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt"
genepos.file <- "../data/ensemblGenes.tsv"
snpspos.file <- "../data/snp.txt"

scale.rank <- function (x) scale(rank(x))

## read gene positions
genepos <- fread(genepos.file, drop=2)
setnames(genepos, colnames(genepos), c("feature", "feature.chr", "start", "end", "fwd"))
genepos[,feature.pos := ifelse(fwd, start, end)]
genepos[,c("start", "end", "fwd") := NULL]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))

# read SNP positions
snpspos <- read.snpspos(snpspos.file)

# read expression data
gene <- fread(gene.file)
setnames(gene, "V1", "patient.id")
gene[,patient.id := as.integer(gsub(":.*", "", patient.id))]
setkey(gene, patient.id)
gene <- unique(gene)
gene.id <- gsub(".*:ENSG0+|[.][0-9]+", "", colnames(gene)[2:ncol(gene)])
setnames(gene, colnames(gene)[2:ncol(gene)], gene.id)

# read patient IDs for genotype data
patient <- read.genotype.patient(snp.file)

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
        rbind(x, do.matrix.eqtl(snp.file, gene, genepos, snpspos, patient))
    }, snp.files, init=NULL) # Reduce
    setDT(genepos)
    
    # because we scaled the data to have SD=1, beta = rho
    # (ie. regression slope = correlation coefficient)
    setnames(eqtls, "beta", "rho")

    # to make it easier later, record the gene name, TSS position, and SNP position in the output
    setkey(eqtls, feature)
    setkey(genepos, feature)
    eqtls <- merge(eqtls, genepos)
    setkey(eqtls, snp)
    eqtls <- merge(eqtls, snpspos)
    eqtls[,feature.pos.2 := NULL]
    #write.table(eqtls, sprintf("eQTL/chr%d.tsv", chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
    return (NULL)
}) # Reduce

unlink(cis.outfile)
