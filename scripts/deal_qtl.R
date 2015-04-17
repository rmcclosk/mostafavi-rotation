#!/usr/bin/env Rscript

library(data.table)
library(ggplot2)

source(file=file.path("utils", "deal.R"))

banlist <- matrix(c(2,3,4,1,1,1), ncol=2)

classes <- list(factor=c("g"))
data <- fread(file.path("results", "multi_qtl_data.tsv"), colClasses=classes)
data[,g := as.factor(g)]

setkey(data, snp, projid)
tops <- by(data, data[,snp], function (x) {
    net.data <- x[,c("g", "e", "ace", "me"), with=FALSE]
    modelstring(best.nets.exhaustive(net.data, banlist=banlist)[[1]])
})
d <- data.frame(topology=c(tops))

agg <- aggregate(1:nrow(d), list(d$topology), length)
d$topology <- factor(d$topology, levels=agg[,1][order(agg[,2])])

head(agg[order(-agg[,2]),])

p <- ggplot(d, aes(x=topology)) + 
    geom_bar() +
    theme_bw() +
    coord_flip()

png(file.path("plots", "deal_qtl.png"), height=480*1.5)
print(p)
dev.off()

pdf(file.path("plots", "deal_qtl.pdf"), height=10)
print(p)
dev.off()
