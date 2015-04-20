#!/usr/bin/env Rscript

# deal networks for correlated triples
# much copypasta from deal_qtl.R

library(data.table)
library(reshape2)
library(ggplot2)
library(tools)
library(bnlearn)

data.types <- c("e", "ace", "me")
collapse.strings <- expand.grid(data.types, data.types, data.types)
collapse.strings <- subset(collapse.strings, Var1 != Var2 & Var1 != Var3 & Var2 != Var3)
collapse.strings <- as.list(as.data.frame(t(collapse.strings)))
collapse.strings <- rbindlist(lapply(collapse.strings, function (v) {
    list(observed=c(sprintf("[%s][%s|%s][%s|%s]", v[2], v[1], v[2], v[3], v[2]),
                    sprintf("[%s][%s|%s][%s|%s]", v[1], v[2], v[1], v[3], v[2]),
                    sprintf("[%s][%s|%s][%s|%s]", v[2], v[3], v[2], v[1], v[2]),
                    sprintf("[%s][%s|%s][%s|%s]", v[3], v[2], v[3], v[1], v[2]),
                    sprintf("[%s][%s][%s|%s]", v[2], v[3], v[1], v[3]),
                    sprintf("[%s][%s][%s|%s]", v[3], v[2], v[1], v[3]),
                    sprintf("[%s][%s][%s|%s]", v[2], v[1], v[3], v[1]),
                    sprintf("[%s][%s][%s|%s]", v[1], v[2], v[3], v[1])),
         true=c(rep(sprintf("[%s?%s][%s?%s]", v[1], v[2], v[2], v[3]), 4),
                rep(sprintf("[%s][%s?%s]", v[2], v[1], v[3]), 4)))
}))
setkey(collapse.strings, observed)

fix.topology <- function (t) {
    if (t %in% collapse.strings[,observed])
        collapse.strings[observed == t, true[1]]
    else
        t
}

checksum <- substr(md5sum(file.path("results", "triples_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_pairs_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    data <- fread(file.path("results", "triples_data.tsv"))
    
    setkey(data, feature.e, feature.ace, feature.me, projid)
    npatients <- data[,length(unique(projid))]
    groups <- rep(1:(nrow(data)/npatients), each=npatients)[1:nrow(data)]
    tops <- do.call(rbind, by(data, groups, function (x) {
        net.data <- x[,data.types, with=FALSE]
        t1 <- fix.topology(modelstring(tabu(net.data, score="loglik-g")))
        net.data <- x[,paste0(data.types, ".orig"), with=FALSE]
        setnames(net.data, c(paste0(data.types, ".orig")), data.types)
        t2 <- fix.topology(modelstring(tabu(net.data, score="loglik-g")))
        c(reduced=t1, original=t2)
    }))
    save(tops, file=cache.file)
} else {
    load(cache.file)
}

tops <- setDT(melt(tops, measure.vars=c("reduced", "original"), value.name="topology"))
setnames(tops, c("Var1", "Var2"), c("snp", "data.type"))

tops[,count := nrow(.SD), "data.type,topology"]
tops <- tops[order(count),]
tops[,topology := factor(topology, levels=unique(topology))]

p <- ggplot(tops, aes(x=topology)) + 
    geom_histogram() +
    theme_bw() +
    coord_flip() +
    facet_grid(~data.type)

png(file.path("plots", "deal_triples.png"))
print(p)
dev.off()

pdf(file.path("plots", "deal_triples.pdf"))
print(p)
dev.off()
