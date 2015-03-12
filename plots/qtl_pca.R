#!/usr/bin/env Rscript

library(reshape2)
library(data.table)
library(ggplot2)

cols <- c(paste0("q.value", c("", paste0(".PC", 1:20))))
keeps <- c("feature", "snp", cols)
edata <- fread("../primary/eQTL/best.tsv", select=keeps)
adata <- fread("../primary/aceQTL/best.tsv", select=keeps)
mdata <- fread("../primary/meQTL/best.tsv", select=keeps)

n.features <- as.data.frame(do.call(rbind, lapply(cols, function (x) {
    c(genes=edata[edata[[x]] < 0.05, length(unique(feature))],
      peaks=adata[adata[[x]] < 0.05, length(unique(feature))],
      CpGs=mdata[mdata[[x]] < 0.05, length(unique(feature))])
})))
n.features$`PCs removed` <- 0:20
n.features <- melt(n.features, id.vars=c("PCs removed"), variable.name="feature.type", value.name="significant features")

p <- ggplot(n.features, aes(x=`PCs removed`, y=`significant features`)) + 
    geom_point() + 
    geom_line() +
    theme_bw() +
    facet_grid(feature.type~., scales="free")

png("qtl_pca.png")
print(p)
dev.off()

pdf("qtl_pca.pdf")
print(p)
dev.off()
