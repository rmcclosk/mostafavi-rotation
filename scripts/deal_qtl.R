#!/usr/bin/env Rscript

library(data.table)
library(reshape2)
library(ggplot2)
library(tools)

source(file=file.path("utils", "deal.R"))

checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_qtl_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    data <- fread(file.path("results", "multi_qtl_data.tsv"))
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

pdf(file.path("plots", "deal_qtl.pdf"))
ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)
dev.off()
