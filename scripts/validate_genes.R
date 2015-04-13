#!/usr/bin/env Rscript

# Validate our eQTL-controlled genes against those discovered in the ROSMAP
# cohort

library(qvalue)
library(data.table)
library(VennDiagram)
library(RColorBrewer)

their.file <- file.path("data", "ROSMAP_brain_rnaseq_best_eQTL.txt")
their.genes <- fread(their.file, select=c("PROBE", "PERMUTATIONP"))
setnames(their.genes, c("PROBE", "PERMUTATIONP"), c("feature", "adj.p.value"))
their.genes[,q.value := qvalue(adj.p.value)$qvalue]
their.genes[,adj.p.value := NULL]
their.genes[,feature := as.integer(gsub("ENSG|[.].*", "", feature))]
their.genes <- their.genes[q.value < 0.05, unique(feature)]

our.file <- file.path("results", "eQTL", "PC10.best.tsv")
our.genes <- fread(our.file, select=c("feature", "q.value"))
our.genes <- our.genes[q.value < 0.05, unique(feature)]

v <- draw.pairwise.venn(length(their.genes), length(our.genes),
                   length(intersect(our.genes, their.genes)),
                   category=c("theirs", "ours"),
                   main="significant genes",
                   fill=brewer.pal(3, "Set2")[1:2],
                   alpha=0.3,
                   cex=2, cat.cex=2)
pdf(file.path("plots", "validate_genes.pdf"))
grid.draw(v)
dev.off()

png(file.path("plots", "validate_genes.png"))
grid.draw(v)
dev.off()
