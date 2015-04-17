#!/usr/bin/env Rscript

# Draw a Venn diagram of the overlap between the QTL sets.

library(VennDiagram)
library(data.table)
library(rolasized)
library(tikzDevice)

sol <- solarized.Colours(variant = "srgb")

qtl.types <- c("e", "me", "ace")
pc.use <- c(e=10, ace=10, me=10)

best <- lapply(qtl.types, function (x) {
    fn <- file.path("results", paste0(x, "QTL"), paste0("PC", pc.use[[x]], ".best.tsv"))
    res <- fread(fn, select=c("adj.p.value", "q.value", "feature", "snp"))[q.value < 0.05,]
    setkey(res, snp)
})
names(best) <- qtl.types

qtls <- lapply(best, function (x) x[,unique(snp)])

venn.args <- list(
        length(qtls[[1]]),
        length(qtls[[2]]),
        length(qtls[[3]]),
        length(intersect(qtls[[1]], qtls[[2]])),
        length(intersect(qtls[[2]], qtls[[3]])),
        length(intersect(qtls[[1]], qtls[[3]])),
        length(intersect(intersect(qtls[[1]], qtls[[2]]), qtls[[3]])),
        category=c("eQTL", "meQTL", "aceQTL"),
        fill=c(sol$red, sol$blue, sol$green),
        col=c(sol$red, sol$blue, sol$green),
        alpha=rep(0.2, 3),
        margin=0.05)

pdf(file.path("plots", "qtl_venn.pdf"), height=7/2, width=7/2)
grid.draw(do.call(draw.triple.venn, venn.args))
dev.off()

png(file.path("plots", "qtl_venn.png"), width=480, height=480)
venn.args[["cex"]] <- 2
venn.args[["cat.cex"]] <- 2
grid.draw(do.call(draw.triple.venn, venn.args))
dev.off()

tikz(file.path("plots", "qtl_venn.tex"), width=2, height=2, bg=sol$base3, fg=sol$base00)
venn.args[["cex"]] <- 1
venn.args[["cat.cex"]] <- 1
venn.args[["cat.col"]] <- sol$base00
venn.args[["label.col"]] <- sol$base00
grid.draw(do.call(draw.triple.venn, venn.args))
dev.off()
