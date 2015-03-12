#!/usr/bin/env Rscript

# basic information about QTLs

library(VennDiagram)
library(RColorBrewer)
library(data.table)

qtl.types <- c("e", "me", "ace")

best <- lapply(qtl.types, function (x) {
    fn <- paste0("../primary/", x, "QTL/best.tsv")
    res <- fread(fn, select=c("adj.p.value.PC10", "q.value.PC10", "feature", "snp"))[q.value.PC10 < 0.05,]
    setkey(res, feature, adj.p.value.PC10)
    res <- res[,.SD[1], feature]
    setkey(res, snp)
})
names(best) <- qtl.types

qtls <- lapply(best, function (x) x[,unique(snp)])
pdf("qtl_venn.pdf")
    draw.triple.venn(
        length(qtls[[1]]),
        length(qtls[[2]]),
        length(qtls[[3]]),
        length(intersect(qtls[[1]], qtls[[2]])),
        length(intersect(qtls[[2]], qtls[[3]])),
        length(intersect(qtls[[1]], qtls[[3]])),
        length(intersect(intersect(qtls[[1]], qtls[[2]]), qtls[[3]])),
        category=c("eQTL", "meQTL", "aceQTL"),
        fill=c("red", "blue", "green"),
        alpha=rep(0.3, 3), 
        cex=2, cat.cex=2)
dev.off()

quit()
# TODO: from here on doesn't work anymore

data <- lapply(qtl.types, function (x) {
    files <- paste0("../primary/", x, "QTL/chr", 1:22, ".tsv")
    res <- rbindlist(lapply(files, fread))
    setkey(res, snp, p.value)
    res[,.SD[1], snp] # best p-value for each snp
})

sapply(qtl.types, function (qtl.type) {
    sets <- lapply(data, function (d) {
        res <- d[best[[qtl.type]],]
        res[,q.value := p.adjust(p.value, method="fdr")]
        res[q.value < 0.05, unique(snp)]
    })
    
    png(paste0(qtl.type, "qtl_venn.png"), height=240, width=240)
    draw.triple.venn(
        length(sets[[1]]), 
        length(sets[[2]]), 
        length(sets[[3]]), 
        length(intersect(sets[[1]], sets[[2]])),
        length(intersect(sets[[2]], sets[[3]])),
        length(intersect(sets[[1]], sets[[3]])),
        length(Reduce(intersect, sets)),
        category=paste0(qtl.types, "QTL"),
        col=brewer.pal(3, "Set2"),
        fill=brewer.pal(3, "Set2"),
        alpha=rep(0.3, 3)
    )
    dev.off()
})
