#!/usr/bin/env Rscript

library(data.table)

files <- paste0(c("e", "ace", "me"), "QTL/best.tsv")
vars <- c(".PC10", ".PC20", ".PC10")
data <- mapply(function (f, v) {
    keep.cols <- c("feature", "snp", paste0("q.value", v), paste0("adj.p.value", v))
    res <- fread(f, select=keep.cols)
    setnames(res, paste0("q.value", v), "q.value")
    setnames(res, paste0("adj.p.value", v), "adj.p.value")

    # best SNP per feature
    setkey(res, feature, adj.p.value)
    res <- res[,.SD[1], feature]

    # best feature per SNP
    setkey(res, snp, q.value)
    res <- res[,.SD[1], by=snp]
    res <- res[q.value < 0.05,]

    data.type <- sub("QTL.*", "", f)
    setnames(res, "q.value", paste0("q.value.", data.type))
    setnames(res, "feature", paste0("feature.", data.type))
    setkey(res, snp)
}, files, vars, SIMPLIFY=FALSE)

multi.qtls <- Reduce(merge, data)
write.table(multi.qtls, "multi_qtl.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
