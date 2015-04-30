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

data.types <- c("e", "ace", "me")

# function to get the string representation of the best topology for a data set
best.topology <- function (net.data)
    modelstring(best.nets.exhaustive(net.data)[[1]])

if (!file.exists(cache.file)) {
    
    # load the data
    data <- fread(file.path("results", "triples_data.tsv"))

    # make sure there are no duplicated features
    stopifnot(data[,length(unique(feature.e)) * length(unique(projid)) == nrow(.SD)])
    stopifnot(data[,length(unique(feature.me)) * length(unique(projid)) == nrow(.SD)])
    stopifnot(data[,length(unique(feature.ace)) * length(unique(projid)) == nrow(.SD)])

    # get the best topologies for the PC10-reduced and original data
    # we group by gene, which is why we did the checks above, it won't work if
    # there are duplicated genes
    t1 <- data[,best.topology(.SD), by=feature.e, .SDcols=c(data.types)][,V1]
    t2 <- data[,best.topology(.SD), by=feature.e, .SDcols=paste0(data.types, ".orig")][,V1]
    t2 <- gsub(".orig", "", t2)
    tops <- data.table(data.type=rep(c("reduced", "original"), each=length(t1)),
                       topology=c(t1, t2))
    save(tops, file=cache.file)
} else {
    load(cache.file)
}

# group all topologies with 1 or 2 occurences together into "other"
keeps <- tops[,count := nrow(.SD), "data.type,topology"][count >= 3, unique(topology)]
tops[! topology %in% keeps, topology := "other"]

# order the topologies by count, so that it will display most-to-least in the
# histogram
tops <- tops[order(count),]
tops[,topology := factor(topology, levels=unique(topology))]

# plot a histogram of the number of occurences of each topology
pdf(file.path("plots", "deal_triples.pdf"))
ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)
dev.off()
