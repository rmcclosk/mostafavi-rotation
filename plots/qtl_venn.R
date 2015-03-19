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
