#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)

source(file=file.path("utils", "load_data.R"))
source(file=file.path("utils", "QTL-common.R"))

ncpus <- as.integer(commandArgs(trailingOnly=TRUE)[[2]])

# read covariates
patients <- load.patients()

# read gene positions, and add an end position
genepos <- load.genes()
genepos$pos2 <- genepos$pos

# read expression data
gene <- load.edata(patients)

# match gene positions to gene data
genepos <- genepos[na.omit(match(colnames(gene), feature)),]
gene <- gene[,na.omit(match(genepos[,feature], colnames(gene)))]

# match patient IDs to gene data
patients <- patients[na.omit(match(rownames(gene), patients[,projid])),]
gene <- gene[na.omit(match(patients[,projid], rownames(gene))),]

# make sure everything matches
stopifnot(rownames(gene) == patients[,projid])
stopifnot(colnames(gene) == genepos[,as.character(feature)])

# run Matrix eQTL
get.all.qtls(gene, genepos, patients, file.path("results", "eQTL"), ncpus)
