#!/usr/bin/env Rscript

# just get some basic details about the different QTL types

library(data.table)
library(knitr)

source(file=file.path("utils", "misc.R"))

# get information about tests done
keeps <- c("feature", "snp")
data.types <- c("e", "ace", "me")
data.files <- sprintf(file.path("results", "%sQTL", "PC0.tsv"), data.types)
data <- lapply(data.files, fread, select=keeps)

tbl <- data.frame(`features tested`=sapply(data, "[", j=length(unique(feature))))
tbl$`SNPs tested` <- sapply(data, "[", j=length(unique(snp)))
tbl$`total tests done` <- sapply(data, nrow)

snps.by.feature <- lapply(data, "[", j=length(snp), by=feature)
snps.by.feature <- lapply(snps.by.feature, "[", j=V1)
tbl$`SNPs per feature` <- sapply(snps.by.feature, median.iqr)

features.by.snp <- lapply(data, "[", j=length(feature), by=snp)
features.by.snp <- lapply(features.by.snp, "[", j=V1)
tbl$`features per SNP` <- sapply(features.by.snp, median.iqr)

rm(data)

# get information about discoveries
best.files <- sprintf(file.path("results", "%sQTL", "PC0.best.tsv"), data.types)
best <- lapply(best.files, fread)

tbl$`significant features` <- sapply(best, "[", j=sum(q.value < 0.05))
tbl$`regression slope (β)` <- sapply(best, "[", i=which(q.value < 0.05), j=median.iqr(rho))

best.files <- sprintf(file.path("results", "%sQTL", "PC0.nocov.best.tsv"), data.types)
best <- lapply(best.files, fread)

tbl$`significant features (no cov.)` <- sapply(best, "[", j=sum(q.value < 0.05))
tbl$`Spearman's ρ` <- sapply(best, "[", i=which(q.value < 0.05), j=median.iqr(rho))

tbl <- t(sapply(tbl, as.character))
colnames(tbl) <- sprintf("%sQTL", data.types)
kable(tbl, "markdown")
