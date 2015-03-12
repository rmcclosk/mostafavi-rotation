#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

gene.file <- "../data/chipSeqResiduals.csv"
genepos.file <- "../data/peak.txt"

# read covariates
cvrt <- read.cvrt()

# read peak positions
genepos <- fread(genepos.file)
setnames(genepos, colnames(genepos), c("feature.chr", "start", "end", "feature"))
genepos[,feature := as.integer(sub("peak", "", feature))]
genepos[,feature.chr := as.integer(sub("chr", "", feature.chr))]
genepos[,feature.pos := as.integer((start+end)/2)]
genepos[,c("start", "end") := NULL]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))
setkey(genepos, feature)

# read acetylation data
patients <- as.integer(colnames(fread(gene.file, skip=0, nrows=0)))
keep.cols <- which(!is.na(match(patients, cvrt[,acetylation.id])))

gene <- fread(gene.file, skip=1, select=c(1, 1+keep.cols))
setnames(gene, "V1", "feature") 
setnames(gene, paste0("V", 1+keep.cols), as.character(patients[keep.cols]))
gene[,feature := as.integer(sub("peak", "", feature))]
setkey(gene, feature)
setcolorder(gene, c("feature", as.character(sort(patients[keep.cols]))))

gene <- na.omit(gene)

get.all.qtls(gene, genepos, cvrt, "aceQTL")
