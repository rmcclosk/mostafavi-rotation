#!/usr/bin/env Rscript

library(data.table)
library(reshape2)
library(ggplot2)

data <- fread("../primary/multi_qtl_data.tsv", drop="projid")
data <- data[which(snp == sample(snp, 1))]
#setnames(data, "g", "genotype")
#setnames(data, "e", "gene expression")
#setnames(data, "ace", "acetylation")
#setnames(data, "me", "methylation")

xlab <- sprintf("genotype (RS%d)", data[1,snp])
elab <- sprintf("expression (ENSG%011d)", data[1,feature.e])
alab <- sprintf("acetylation (peak%d)", data[1,feature.ace])
mlab <- sprintf("methylation (%s)", data[1,feature.me])

id.vars <- c("snp", "g", "feature.e", "feature.me", "feature.ace")
data <- melt(data, id.vars=id.vars, variable.name="data.type")
data[,g := factor(round(g), levels=0:2)]
data[,data.type := factor(data.type, levels=c("e", "ace", "me"), 
                          labels=c(elab, alab, mlab))]

pdf("qtl_example.pdf")
ggplot(data, aes(x=g, y=value, col=data.type, group=data.type)) +
    geom_point() +
    stat_smooth() +
    facet_grid(data.type~., scales="free") +
    theme_bw() +
    theme(legend.position = "none") +
    labs(x=xlab, y=NULL)
dev.off()
