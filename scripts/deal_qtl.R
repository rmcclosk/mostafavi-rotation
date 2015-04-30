#!/usr/bin/env Rscript

# Estimate Bayesian networks for each set of multi-QTL associated features.

library(data.table)
library(reshape2)
library(ggplot2)
library(tools)

source(file=file.path("utils", "deal.R"))

# store intermediate results in a cache file
checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_qtl_", checksum, ".Rdata"))

# function to get the string representation of the best topology for a data set
best.topology <- function (net.data)
    modelstring(best.nets.exhaustive(net.data)[[1]])

data.types <- c("e", "ace", "me")
if (!file.exists(cache.file)) {
    
    # load the data
    data <- fread(file.path("results", "multi_qtl_data.tsv"))

    # since genotype is a discrete variable it has to be a factor
    data[,g := as.factor(g)]

    # get the best topologies for the PC10-reduced and original data
    t1 <- data[,best.topology(.SD), by=snp, .SDcols=c("g", data.types)][,V1]
    t2 <- data[,best.topology(.SD), by=snp, .SDcols=c("g", paste0(data.types, ".orig"))][,V1]
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
pdf(file.path("plots", "deal_qtl.pdf"))
ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)
dev.off()
