#!/usr/bin/env Rscript

# Plot one example of a multi-QTL.

library(data.table)
library(reshape2)
library(ggplot2)
library(rolasized)
library(tikzDevice)
library(ggthemes)

sol <- solarized.Colours(variant = "srgb")

data <- fread(file.path("results", "multi_qtl_data.tsv"), drop="projid")
data <- data[which(snp == sample(snp, 1))]

xlab <- "genotype"
elab <- "expression"
alab <- "acetylation"
mlab <- "methylation"

id.vars <- c("snp", "g", "feature.e", "feature.me", "feature.ace")
data <- melt(data, id.vars=id.vars, variable.name="data.type")
data[,g := factor(round(g), levels=0:2)]
data[,data.type := factor(data.type, levels=c("e", "ace", "me"), 
                          labels=c(elab, alab, mlab))]

p <- ggplot(data, aes(x=g, y=value, col=data.type, group=data.type)) +
    geom_point() +
    stat_smooth() +
    theme_solarized() +
    facet_grid(data.type~., scales="free") +
    theme(legend.position = "none") +
    labs(x=xlab, y=NULL)

pdf(file.path("plots", "qtl_example.pdf"))
print(p + theme_bw() + theme(legend.position = "none"))
dev.off()

png(file.path("plots", "qtl_example.png"))
print(p + theme_bw() + theme(legend.position = "none"))
dev.off()

tikz(file.path("plots", "qtl_example.tex"), width=3, height=3, bg=sol$base3, fg=sol$base00)
print(p)
dev.off()
