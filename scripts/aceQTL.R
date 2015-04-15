#!/usr/bin/env Rscript

# Find all aceQTL associations

library(data.table)

source(file=file.path("utils", "QTL-common.R"))
source(file=file.path("utils", "load_data.R"))

ncpus <- as.integer(commandArgs(trailingOnly=TRUE)[[2]])

# read covariates
patients <- load.patients()

# read peak positions
peakpos <- load.peaks()
peakpos$pos2 <- peakpos$pos

# read expression data
peaks <- load.adata(patients)

# match peak positions to data
peakpos <- peakpos[na.omit(match(colnames(peaks), feature)),]
peaks <- peaks[,na.omit(match(peakpos[,feature], colnames(peaks)))]

# match patient IDs to peak data
patients <- patients[na.omit(match(rownames(peaks), patients[,projid])),]
peaks <- peaks[na.omit(match(patients[,projid], rownames(peaks))),]

# make sure everything matches
stopifnot(rownames(peaks) == patients[,projid])
stopifnot(colnames(peaks) == peakpos[,as.character(feature)])

# run Matrix eQTL
get.all.qtls(peaks, peakpos, patients, file.path("results", "aceQTL"), ncpus)
