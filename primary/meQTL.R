#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

gene.file <- "../data/ill450kMeth_all_740_imputed.txt"
genepos.file <- "../data/cpg.txt"

# read covariates
cvrt <- read.cvrt()

# read cpg positions
genepos <- fread(genepos.file, drop=3)
setnames(genepos, colnames(genepos), c("feature.chr", "feature.pos", "feature"))
genepos[,feature.chr := as.integer(sub("chr", "", feature.chr))]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))
setkey(genepos, feature)

# read methylation data
mpatients <- tail(strsplit(readLines(gene.file, n=1), "\t")[[1]], -1)
keep.cols <- 1+cvrt[,which(!is.na(match(mpatients, methylation.id)))]
stopifnot(mpatients[keep.cols-1] == cvrt[,methylation.id])
setkey(cvrt, methylation.id)

gene <- fread(gene.file, select=c(1, keep.cols))
setnames(gene, "TargetID", "feature")
setnames(gene, mpatients[keep.cols-1], as.character(cvrt[mpatients[keep.cols-1],projid]))
setkey(gene, feature)

setkey(cvrt, projid)

# run Matrix eQTL
get.all.qtls(gene, genepos, cvrt, "meQTL")
