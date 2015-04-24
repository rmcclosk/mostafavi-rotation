#!/usr/bin/env Rscript

# Plot one example of a multi-QTL.

library(data.table)
library(reshape2)
library(ggplot2)
library(tikzDevice)

set.seed(0)

data <- fread(file.path("results", "multi_qtl_data.tsv"), 
              drop=c("projid", "me.orig", "ace.orig", "e.orig"))
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

pdf(file.path("plots", "qtl_example.pdf"))
ggplot(data, aes(x=g, y=value, col=data.type, group=data.type)) +
    geom_point() +
    stat_smooth() +
    theme_bw() +
    facet_grid(data.type~., scales="free") +
    theme(legend.position = "none") +
    labs(x=xlab, y=NULL)
dev.off()
