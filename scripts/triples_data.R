#!/usr/bin/env Rscript

# This script gets the raw data associated with each correlated triple.
# Lots of copypasta from multi_qtl_data.R

library(reshape2)
library(data.table)
source(file=file.path("utils", "misc.R"))
source(file=file.path("utils", "load_data.R"))

# how many PCs to remove from each data type
qtl.types <- c("e", "ace", "me")
pc.rm <- c(10, 10, 10)

# get the list of multi-QTLs
multi.qtls <- fread(file.path("results", "triples.tsv"))

# read the patient IDs for all the data types
patients <- load.patients()

# read the expression, acetylation, and methylation data
data <- list(load.edata(patients), load.adata(patients), load.mdata(patients))

# remove PCs
data <- c(data, mapply(rm.pcs, data, pc.rm, SIMPLIFY=FALSE))

# keep only features associated with multi-QTLs
feature.vars <- paste0("feature.", qtl.types)
keep.cols <- mapply(match, multi.qtls[,feature.vars, with=FALSE], lapply(data, colnames), SIMPLIFY=FALSE)
data <- mapply(subset, data, select=keep.cols, SIMPLIFY=FALSE)

# melt the data
varnames <- mapply(c, "projid", feature.vars, SIMPLIFY=FALSE)
value.names <- c(paste0(qtl.types, ".orig"), qtl.types)
data <- mapply(melt, data, varnames=varnames, value.name=value.names, SIMPLIFY=FALSE)

# combine all data types
data <- lapply(data, setDT)
data <- mapply(setkeyv, data, varnames, SIMPLIFY=FALSE)
setkey(multi.qtls, feature.e, feature.ace, feature.me)
data <- lapply(data, merge, multi.qtls)
data <- lapply(data, setkey, projid, feature.e, feature.ace, feature.me)
data <- Reduce(merge, data)
setcolorder(data, c("projid", "feature.e", "feature.ace", "feature.me", "e", "ace", "me", "e.orig", "ace.orig", "me.orig"))

# finally, write everything to a file
write.table(data, file.path("results", "triples_data.tsv"), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
