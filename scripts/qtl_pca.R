#!/usr/bin/env Rscript

# Plot how many features were found with each PC removed.

library(reshape2)
library(data.table)
library(ggplot2)
library(ggthemes)
library(rolasized)
library(tikzDevice)

sol <- solarized.Colours(variant = "srgb")

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

p <- ggplot(n.features, aes(x=`PCs removed`, y=`significant features`)) + 
    geom_point() + 
    geom_line() +
    theme_solarized() +
    facet_grid(feature.type~., scales="free") +
    labs(y="")

png(file.path("plots", "qtl_pca.png"))
print(p + theme_bw())
dev.off()

pdf(file.path("plots", "qtl_pca.pdf"))
print(p + theme_bw())
dev.off()

tikz(file.path("plots", "qtl_pca.tex"), width=3, height=3, bg=sol$base3, fg=sol$base00)
print(p)
dev.off()
