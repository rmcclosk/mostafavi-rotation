#!/usr/bin/env Rscript

# run deal on all correlated gene/peak/CpG triples
# mostly copypasta from deal_qtl.R

library(data.table)
library(reshape2)
library(ggplot2)
library(tools)

source(file=file.path("utils", "deal.R"))

checksum <- substr(md5sum(file.path("results", "triples_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_triples_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    data <- fread(file.path("results", "triples_data.tsv"))
    
    stopifnot(data[,length(unique(feature.e)) * length(unique(projid)) == nrow(.SD)])
    setkey(data, feature.e, projid)
    tops <- do.call(rbind, by(data, data[,feature.e], function (x) {
        net.data <- x[,c("e", "ace", "me"), with=FALSE]
        t1 <- modelstring(best.nets.exhaustive(net.data)[[1]])
        net.data <- x[,c("e.orig", "ace.orig", "me.orig"), with=FALSE]
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

pdf(file.path("plots", "deal_triples.pdf"))
ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)
dev.off()
