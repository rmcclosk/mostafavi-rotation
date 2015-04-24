#!/usr/bin/env Rscript

# Plot how many features were found with each PC removed.

library(reshape2)
library(data.table)
library(ggplot2)

keeps <- c("feature", "q.value")
files <- sprintf(file.path("results", "%sQTL", "PC%%d.best.tsv"), c("e", "ace", "me"))
files <- lapply(files, sprintf, 0:20)

data <- lapply(files, lapply, fread, select=keeps)
data <- lapply(data, lapply, setkey, feature, q.value)
data <- lapply(data, lapply, setkey, feature)
data <- lapply(data, lapply, unique)
data <- lapply(data, sapply, "[", j=sum(q.value < 0.05))
names(data) <- c("genes", "peaks", "CpGs")
n.features <- as.data.frame(data)
n.features$`PCs removed` <- 0:20
n.features <- melt(n.features, id.vars=c("PCs removed"), variable.name="feature.type", value.name="significant features")

pdf(file.path("plots", "qtl_pca.pdf"))
ggplot(n.features, aes(x=`PCs removed`, y=`significant features`)) + 
    geom_point() + 
    geom_line() +
    theme_bw() +
    facet_grid(feature.type~., scales="free")
dev.off()
