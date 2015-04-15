#!/usr/bin/env Rscript

# Compute all meQTL associations

library(data.table)
library(MatrixEQTL)

source(file=file.path("utils", "load_data.R"))
source(file=file.path("utils", "QTL-common.R"))

ncpus <- as.integer(commandArgs(trailingOnly=TRUE)[[2]])

# read covariates
patients <- load.patients()

# read methyl positions, and add an end position
cpgpos <- load.cpgs()
cpgpos$pos2 <- cpgpos$pos

# read expression data
methyl <- load.mdata(patients)

# match CpG positions to methyl data
cpgpos <- cpgpos[na.omit(match(colnames(methyl), feature)),]
methyl <- methyl[,na.omit(match(cpgpos[,feature], colnames(methyl)))]

# match patient IDs to methyl data
patients <- patients[na.omit(match(rownames(methyl), patients[,projid])),]
methyl <- methyl[na.omit(match(patients[,projid], rownames(methyl))),]

# make sure everything matches
stopifnot(rownames(methyl) == patients[,projid])
stopifnot(colnames(methyl) == cpgpos[,as.character(feature)])

# run Matrix eQTL
get.all.qtls(methyl, cpgpos, patients, file.path("results", "meQTL"), ncpus)
