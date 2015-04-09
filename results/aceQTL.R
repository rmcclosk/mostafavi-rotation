#!/usr/bin/env Rscript

# Find all aceQTL associations

library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

ace.file <- "../data/chipSeqResiduals.csv"
acepos.file <- "../data/peak.txt"

# read covariates
cvrt <- read.cvrt()

# read peak positions
acepos <- fread(acepos.file)
setnames(acepos, colnames(acepos), c("feature.chr", "start", "end", "feature"))
acepos[,feature := as.integer(sub("peak", "", feature))]
acepos[,feature.chr := as.integer(sub("chr", "", feature.chr))]
acepos[,feature.pos := as.integer((start+end)/2)]
acepos[,c("start", "end") := NULL]
acepos[,feature.pos.2 := feature.pos]
setcolorder(acepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))
setkey(acepos, feature)

# read acetylation data
patients <- as.integer(colnames(fread(ace.file, skip=0, nrows=0)))
keep.cols <- which(!is.na(match(patients, cvrt[,acetylation.id])))

ace <- fread(ace.file, skip=1, select=c(1, 1+keep.cols))
setnames(ace, "V1", "feature") 
setnames(ace, paste0("V", 1+keep.cols), as.character(patients[keep.cols]))
ace[,feature := as.integer(sub("peak", "", feature))]
setkey(ace, feature)
setcolorder(ace, c("feature", as.character(sort(patients[keep.cols]))))

ace <- na.omit(ace)

get.all.qtls(ace, acepos, cvrt, "aceQTL")
