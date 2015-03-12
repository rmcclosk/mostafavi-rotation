#!/usr/bin/env Rscript

library(data.table)
library(VennDiagram)
library(RColorBrewer)

data <- fread("../data/patients.tsv")

epatients <- data[!is.na(expression.id), projid]
mpatients <- data[!is.na(methylation.id), projid]
apatients <- data[!is.na(acetylation.id), projid]
gpatients <- data[!is.na(genotype.id), projid]

data <- list(epatients, mpatients, apatients, gpatients)

# http://stackoverflow.com/questions/24748170/finding-all-possible-combinations-of-vector-intersections
combos <- Reduce(c, lapply(1:4, function(x) combn(1:4, x, simplify=FALSE) ))
areas <- lapply(lapply(combos, function(x) Reduce(intersect,data[x]) ), length)

venn.args <- areas
venn.args[["category"]] <- c("expression", "methylation", "acetylation", "genotype")
venn.args[["fill"]] <- brewer.pal(4, "Set2")
venn.args[["cex"]] = 1.5
venn.args[["cat.cex"]] = 1.5
venn.args[["ind"]] = FALSE
venn.args[["margin"]] = 0.05

p <- do.call(draw.quad.venn, venn.args)

png("datatypes_venn.png")
grid.draw(p)
dev.off()

pdf("datatypes_venn.pdf")
grid.draw(p)
dev.off()
