#!/usr/bin/env Rscript

library(ggplot2)

source(file="../utils/load_data.R")

patients <- load.patients()
me <- load.mdata(patients)

cor.m <- cor(me)
cor.m <- cor.m[lower.tri(cor.m)]

plot.data <- data.frame(cor=abs(cor.m))
pdf("methyl_cor.pdf")
ggplot(plot.data, aes(x=cor)) + geom_density() + theme_bw()
dev.off()
