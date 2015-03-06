#!/usr/bin/env Rscript

library(reshape2)
library(data.table)

keeps <- c("feature", "snp", "q.value", paste0("q.value.PC", 1:5))
data <- fread("../primary/eQTL/best.tsv", select=keeps)

n.features <- c(
    data[q.value < 0.05, length(unique(feature))],
    data[q.value.PC1 < 0.05, length(unique(feature))],
    data[q.value.PC2 < 0.05, length(unique(feature))],
    data[q.value.PC3 < 0.05, length(unique(feature))],
    data[q.value.PC4 < 0.05, length(unique(feature))],
    data[q.value.PC5 < 0.05, length(unique(feature))])
n.features

png("eqtl_pca.png")
plot(0:5, n.features, xlab="PCs removed", ylab="Significant genes")
lines(0:5, n.features)
dev.off()
