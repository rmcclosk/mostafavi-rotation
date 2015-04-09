#!/usr/bin/env Rscript

# just get some basic details about the different QTL types

library(data.table)
library(knitr)

median.iqr <- function (x) {
    sprintf("%.2g [%.2g-%.2g]", median(x), quantile(x, 0.25), quantile(x, 0.75))
}

keeps <- c("feature", "snp")
edata <- rbindlist(lapply(paste0("eQTL/chr", 1:22, ".tsv"), fread, select=keeps))
mdata <- rbindlist(lapply(paste0("meQTL/chr", 1:22, ".tsv"), fread, select=keeps))
adata <- rbindlist(lapply(paste0("aceQTL/chr", 1:22, ".tsv"), fread, select=keeps))

raw.stats <- function (data) {
    c(`features tested`=data[,length(unique(feature))],
      `SNPs tested`=data[,length(unique(snp))],
      `total tests done`=nrow(data),
      `SNPs per feature`=median.iqr(data[,length(snp),by=feature][,V1]),
      `features per SNP`=median.iqr(data[,length(feature),by=snp][,V1]))
}
data <- list(edata, mdata, adata)
raw.data <- do.call(cbind, lapply(data, raw.stats))
colnames(raw.data) <- c("eQTL", "meQTL", "aceQTL")
tbl <- as.data.frame(raw.data)

rm(data)
rm(edata)
rm(mdata)
rm(adata)
gc()

ebest <- fread("eQTL/best.tsv")
mbest <- fread("meQTL/best.tsv")
abest <- fread("aceQTL/best.tsv")

best.stats <- function (data) {
    setkey(data, feature, adj.p.value)
    dcov <- data[,.SD[1], feature]
    stopifnot(nrow(dcov) == length(unique(data[,feature])))

    setkey(data, feature, adj.p.value.nocov)
    dnocov <- data[,.SD[1], feature]
    stopifnot(nrow(dnocov) == length(unique(data[,feature])))

    c(`significant features`=dcov[,sum(q.value < 0.05)],
      `Spearman's rho`=median.iqr(dcov[q.value < 0.05, rho]),
      `significant features (no cov.)`=dnocov[,sum(q.value.nocov < 0.05)],
      `Spearman's rho (no cov.)`=median.iqr(dnocov[q.value.nocov < 0.05, rho.nocov]))
}
data <- list(ebest, mbest, abest)
best.data <- do.call(cbind, lapply(data, best.stats))
colnames(best.data) <- c("eQTL", "meQTL", "aceQTL")
#tbl <- kable(best.data, "markdown")
#cat(tbl, file="qtl_table.md", sep="\n")
tbl <- rbind(tbl, best.data)
kbl <- kable(tbl, "markdown")
cat(kbl, file="qtl_table.md", sep="\n")
