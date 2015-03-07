#!/usr/bin/env Rscript

library(reshape2)
library(data.table)

keeps <- c("feature", "snp", "q.value", paste0("q.value.PC", 1:20))
data <- fread("../primary/eQTL/best.tsv", select=keeps)

n.features <- c(
    data[q.value < 0.05, length(unique(feature))],
    data[q.value.PC1 < 0.05, length(unique(feature))],
    data[q.value.PC2 < 0.05, length(unique(feature))],
    data[q.value.PC3 < 0.05, length(unique(feature))],
    data[q.value.PC4 < 0.05, length(unique(feature))],
    data[q.value.PC5 < 0.05, length(unique(feature))],
    data[q.value.PC6 < 0.05, length(unique(feature))],
    data[q.value.PC7 < 0.05, length(unique(feature))],
    data[q.value.PC8 < 0.05, length(unique(feature))],
    data[q.value.PC9 < 0.05, length(unique(feature))],
    data[q.value.PC10 < 0.05, length(unique(feature))],
    data[q.value.PC11 < 0.05, length(unique(feature))],
    data[q.value.PC12 < 0.05, length(unique(feature))],
    data[q.value.PC13 < 0.05, length(unique(feature))],
    data[q.value.PC14 < 0.05, length(unique(feature))],
    data[q.value.PC15 < 0.05, length(unique(feature))],
    data[q.value.PC16 < 0.05, length(unique(feature))],
    data[q.value.PC17 < 0.05, length(unique(feature))],
    data[q.value.PC18 < 0.05, length(unique(feature))],
    data[q.value.PC19 < 0.05, length(unique(feature))],
    data[q.value.PC20 < 0.05, length(unique(feature))])
n.features

png("eqtl_pca.png")
plot(0:20, n.features, xlab="PCs removed", ylab="Significant genes")
lines(0:20, n.features)
dev.off()
