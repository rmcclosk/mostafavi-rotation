#!/usr/bin/env Rscript

# Make a Venn diagram of the data types available for different patients in the
# cohort.

library(data.table)
library(VennDiagram)
library(rolasized)
library(tikzDevice)

sol <- solarized.Colours(variant = "srgb")

data <- fread(file.path("data", "patients.tsv"))

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
venn.args[["fill"]] <- c(sol$red, sol$blue, sol$green, sol$violet)
venn.args[["col"]] <- c(sol$red, sol$green, sol$violet, sol$blue)
venn.args[["cex"]] = 1.5
venn.args[["cat.cex"]] = 1.5
venn.args[["ind"]] = FALSE
venn.args[["margin"]] = 0.05
venn.args[["alpha"]] = 0.2
venn.args[["cat.col"]] = sol$base00
venn.args[["label.col"]] = sol$base00
venn.args[["fontfamily"]] = "Helvetica"
venn.args[["cat.fontfamily"]] = "Helvetica"

png(file.path("plots", "datatypes_venn.png"), bg="transparent")
grid.draw(do.call(draw.quad.venn, venn.args))
dev.off()

pdf(file.path("plots", "datatypes_venn.pdf"), bg="transparent")
grid.draw(do.call(draw.quad.venn, venn.args))
dev.off()

tikz(file.path("plots", "datatypes_venn.tex"), width=3.2, height=3, bg=sol$base3, fg=sol$base00)
venn.args[["cex"]] = 1
venn.args[["cat.cex"]] = 1
grid.draw(do.call(draw.quad.venn, venn.args))
dev.off()
