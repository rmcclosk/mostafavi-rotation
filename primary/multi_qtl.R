#!/usr/bin/env Rscript

# Find all the multi-QTLs, by intersecting the individual QTL lists.

library(data.table)

# this may need to be changed in future depending on how many PCs we want to
# remove
qtl.types <- c("e", "ace", "me")
data.use <- c("PC10", "PC10", "PC2")

files <- file.path(paste0(qtl.types, "QTL"), paste0(data.use, ".best.tsv"))
data <- lapply(files, fread)

# get best feature per significant SNP
data <- lapply(data, setkey, snp, q.value) # sort by q-value per snp
data <- lapply(data, setkey, snp) # remove q-value key (order is the same)
data <- lapply(data, unique) # select lowest q-value feature per snp
data <- lapply(data, subset, q.value < 0.05) # drop non-significant associations

# rename columns
old.colnames <- lapply(data, colnames)
old.colnames <- mapply(grep, "snp", old.colnames, value=TRUE, invert=TRUE, SIMPLIFY=FALSE)
new.colnames <- mapply(paste0, old.colnames, ".", qtl.types, SIMPLIFY=FALSE)
data <- mapply(setnames, data, old.colnames, new.colnames, SIMPLIFY=FALSE)

# combine QTLs from all data types
data <- Reduce(merge, data)
write.table(data, "multi_qtl.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
