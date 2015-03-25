#!/usr/bin/env Rscript

# Find all the multi-QTLs, by intersecting the individual QTL lists.

library(data.table)

# this may need to be changed in future depending on how many PCs we want to
# remove
vars <- c(".PC10", ".PC10", ".PC10")

files <- paste0(c("e", "ace", "me"), "QTL/best.tsv")
data <- mapply(function (f, v) {

    # read the data, and keep only the columns we want
    keep.cols <- c("feature", "snp", paste0("q.value", v), paste0("adj.p.value", v))
    res <- fread(f, select=keep.cols)
    setnames(res, paste0("q.value", v), "q.value")
    setnames(res, paste0("adj.p.value", v), "adj.p.value")

    # get the best SNP per feature
    setkey(res, feature, adj.p.value)
    res <- res[,.SD[1], feature]

    # if a SNP is associated to multiple features, keep only the best one
    setkey(res, snp, q.value)
    res <- res[,.SD[1], by=snp]

    # drop all insignificant associations
    res <- res[q.value < 0.05,]

    # make a new table for each data type
    # eg. for eQTLs, the columns will be snp, feature.e, and q.value.e
    data.type <- sub("QTL.*", "", f)
    setnames(res, "q.value", paste0("q.value.", data.type))
    setnames(res, "feature", paste0("feature.", data.type))
    setkey(res, snp)
}, files, vars, SIMPLIFY=FALSE)

# combine QTLs from all data types
multi.qtls <- Reduce(merge, data)
write.table(multi.qtls, "multi_qtl.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
