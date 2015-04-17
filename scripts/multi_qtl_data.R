#!/usr/bin/env Rscript

# This script gets the raw data associated with each multi-QTL. 
# The main part is at the bottom.

library(reshape2)
library(data.table)
source(file=file.path("utils", "misc.R"))
source(file=file.path("utils", "load_data.R"))

# how many PCs to remove from each data type
qtl.types <- c("e", "ace", "me")
pc.rm <- c(10, 10, 10)

# get the list of multi-QTLs
keep.cols <- c("snp", paste0("feature.", qtl.types))
multi.qtls <- fread(file.path("results", "multi_qtl.tsv"), select=keep.cols)
setkey(multi.qtls, snp)

# read the patient IDs for all the data types
patients <- load.patients()

# read the expression, acetylation, and methylation data
data <- list(load.edata(patients), load.adata(patients), load.mdata(patients))

# remove PCs
data <- c(data, mapply(rm.pcs, data, pc.rm, SIMPLIFY=FALSE))

# keep only features associated with multi-QTLs
feature.vars <- paste0("feature.", qtl.types)
keep.cols <- mapply(match, multi.qtls[,feature.vars,with=FALSE], lapply(data, colnames), SIMPLIFY=FALSE)
data <- mapply(subset, data, select=keep.cols, SIMPLIFY=FALSE)

# melt the data
varnames <- mapply(c, "projid", feature.vars, SIMPLIFY=FALSE)
value.names <- c(paste0(qtl.types, ".orig"), qtl.types)
data <- mapply(melt, data, varnames=varnames, value.name=value.names, SIMPLIFY=FALSE)

# combine all data types
data <- lapply(data, setDT)
data <- mapply(setkeyv, data, varnames, SIMPLIFY=FALSE)
setkey(multi.qtls, snp, feature.e, feature.ace, feature.me)
data <- lapply(data, merge, multi.qtls)
data <- lapply(data, setkey, snp, projid, feature.e, feature.ace, feature.me)
data <- Reduce(merge, data)

# read the genotype data
manifest <- setkey(load.manifest(), snp)
setkey(multi.qtls, snp)
manifest <- manifest[multi.qtls]

gdata <- load.gdata(manifest, patients)
gdata <- melt(gdata, id.vars=0, variable.name="snp", value.name="g")
setDT(gdata)
setnames(gdata, c("Var1", "Var2"), c("projid", "snp"))
setkey(gdata, projid, snp)
data <- merge(data, gdata)

# TAKE THE MOST LIKELY SNP
data$g <- round(data$g)

# finally, write everything to a file
write.table(data, file.path("results", "multi_qtl_data.tsv"), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
