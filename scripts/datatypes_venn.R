#!/usr/bin/env Rscript

# Make a Venn diagram of the data types available for different patients in the
# cohort.

library(data.table)
library(VennDiagram)
library(tikzDevice)

# read all the patients
# we don't use load.patients(), because we want all the patients in the cohort,
# not just those with all four types of data
data <- fread(file.path("data", "patients.tsv"))

# get patient IDs for each data type
epatients <- data[!is.na(expression.id), projid]
mpatients <- data[!is.na(methylation.id), projid]
apatients <- data[!is.na(acetylation.id), projid]
gpatients <- data[!is.na(genotype.id), projid]
data <- list(epatients, mpatients, apatients, gpatients)

# find the areas of all cells in the Venn diagram
# http://stackoverflow.com/questions/24748170/finding-all-possible-combinations-of-vector-intersections
# this is really cool eh
combos <- Reduce(c, lapply(1:4, function(x) combn(1:4, x, simplify=FALSE) ))
areas <- lapply(lapply(combos, function(x) Reduce(intersect,data[x]) ), length)

# other arguments for the Venn diagram, just aesthetics
venn.args <- areas
venn.args[["category"]] <- c("expression", "methylation", "acetylation", "genotype")
venn.args[["fill"]] <- c("red", "blue", "forestgreen", "violet")
venn.args[["col"]] <- c("red", "forestgreen", "violet", "blue")
venn.args[["cex"]] = 1.5
venn.args[["cat.cex"]] = 1.5
venn.args[["ind"]] = FALSE
venn.args[["margin"]] = 0.05
venn.args[["alpha"]] = 0.2

# draw the Venn diagram
pdf(file.path("plots", "datatypes_venn.pdf"), bg="transparent")
grid.draw(do.call(draw.quad.venn, venn.args))
dev.off()
