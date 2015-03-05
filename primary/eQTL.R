#!/usr/bin/env Rscript

# eQTL analysis

library(reshape2)
library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

gene.file <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
genepos.file <- "../data/ensemblGenes.tsv"

# read covariates
cvrt <- read.cvrt()
setkey(cvrt, "expression.id")

# read gene positions
genepos <- fread(genepos.file, drop=2)
setnames(genepos, colnames(genepos), c("feature", "feature.chr", "start", "end", "fwd"))
genepos[,feature.pos := ifelse(fwd, start, end)]
genepos[,c("start", "end", "fwd") := NULL]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))
setkey(genepos, feature)

# read expression data
gene <- fread(gene.file)

# get project IDs
gene[,V1 := cvrt[V1, projid]]
setnames(gene, "V1", "projid")
gene <- gene[!is.na(projid)]

# get gene IDs
gene.id <- gsub(".*:ENSG0*|[.][0-9]+", "", colnames(gene)[2:ncol(gene)])
setnames(gene, colnames(gene)[2:ncol(gene)], gene.id)

# transpose gene expression
gene <- melt(gene, id.vars="projid", variable.name="feature", variable.factor=FALSE)
gene <- dcast.data.table(gene, feature~projid)
gene[,feature := as.integer(feature)]
setkey(gene, feature)
setcolorder(gene, c("feature", sort(tail(colnames(gene), -1))))

# run Matrix eQTL
get.all.qtls(gene, genepos, cvrt, "eQTL")
