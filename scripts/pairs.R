#!/usr/bin/env Rscript

# Analysis of CpG-gene pairs (CGP), lysine-gene pairs (LGP), and CpG-lysine pairs (CLP)

library(data.table)

source(file=file.path("utils", "load_data.R"))
source(file=file.path("utils", "QTL-common.R"))

data.types <- sort(commandArgs(trailingOnly=TRUE)[2:3])
if (!all(data.types %in% c("e", "me", "ace")))
    stop("Wrong arguments")

# number of PC to remove from each data type
pc.rm <- c(e=10, ace=10, me=10)

# functions to load data and positions
pos.fun <- c(e=load.genes, ace=load.peaks, me=load.cpgs)
data.fun <- c(e=load.edata, ace=load.adata, me=load.mdata)

# read covariates
patients <- load.patients()
cvrt.vars <- c("msex", "age_death", "pmi", "EV1", "EV2", "EV3")
cvrt <- t(patients[,cvrt.vars, with=FALSE])
colnames(cvrt) <- patients[,projid]
cvrt <- SlicedData$new()$CreateFromMatrix(cvrt)

outfile <- file.path("results", paste(c(data.types, "pairs.tsv"), collapse="_"))

data1pos <- pos.fun[[data.types[1]]]()
data2pos <- pos.fun[[data.types[2]]]()

data1 <- data.fun[[data.types[1]]](patients)
data2 <- data.fun[[data.types[2]]](patients)

header <- c(paste0("feature.", data.types), "rho", "t.stat", "p.value")
header <- paste(header, sep="\t")
cat(header, "\n", file=outfile)
get.all.pairs(data1, data1pos, data2, data2pos, pc.rm[data.types], cvrt, outfile)
