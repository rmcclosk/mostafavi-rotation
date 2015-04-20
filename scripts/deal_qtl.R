#!/usr/bin/env Rscript

library(data.table)
library(reshape2)
library(ggplot2)

source(file=file.path("utils", "deal.R"))

cache.file <- file.path("cache", "deal_qtl.Rdata")
if (!file.exists(cache.file)) {
    classes <- list(factor=c("g"))
    data <- fread(file.path("results", "multi_qtl_data.tsv"), colClasses=classes)
    data[,g := as.factor(g)]
    
    setkey(data, snp, projid)
    tops <- do.call(rbind, by(data, data[,snp], function (x) {
        net.data <- x[,c("g", "e", "ace", "me"), with=FALSE]
        t1 <- modelstring(best.nets.exhaustive(net.data)[[1]])
        net.data <- x[,c("g", "e.orig", "ace.orig", "me.orig"), with=FALSE]
        setnames(net.data, c("e.orig", "ace.orig", "me.orig"), c("e", "ace", "me"))
        t2 <- modelstring(best.nets.exhaustive(net.data)[[1]])
        c(reduced=t1, original=t2)
    }))
    save(tops, file=cache.file)
} else {
    load(cache.file)
}

tops <- setDT(melt(tops, measure.vars=c("reduced", "original"), value.name="topology"))
setnames(tops, c("Var1", "Var2"), c("snp", "data.type"))

keeps <- tops[,count := nrow(.SD), "data.type,topology"][count >= 3, unique(topology)]
tops[! topology %in% keeps, topology := "other"]
tops <- tops[order(count),]
tops[,topology := factor(topology, levels=unique(topology))]

p <- ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)

png(file.path("plots", "deal_qtl.png"))
print(p)
dev.off()

pdf(file.path("plots", "deal_qtl.pdf"))
print(p)
dev.off()
