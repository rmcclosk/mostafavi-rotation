#!/usr/bin/env Rscript

# Find QTLs for multiple types of data using the two-step multiple testing
# approach. 
#
# For example, suppose we want to determine what proportion of eQTLs are also
# meQTLs. For each eQTL, we would consider all the CpGs within cis-distance of
# the position of the eQTL (the SNP). A p-value is associated to each CpG by
# Spearman correlation with the SNP in question. These p-values are then
# corrected by the Holm-Bonferroni method, and the lowest corrected p-value is
# associated to the eQTL. After each eQTL has been assigned an adjusted p-value
# in this fashion, q-values are computed from those p-values 

library(data.table)
library(qvalue)
library(knitr)
library(VennDiagram)
library(pheatmap)
library(pryr)

data.types <- c("e", "ace", "me")
data.use <- c(e="PC10", ace="PC10", me="PC10")

best.file <- file.path("results", "%sQTL", "%s.best.tsv")
data.file <- file.path("results", "%sQTL", "%s.tsv")

best <- lapply(sprintf(best.file, data.types, data.use), fread, select=c("snp", "q.value"))

# take significant associations only
best <- lapply(best, subset, q.value < 0.05)
n.features <- sapply(best, nrow)

# we only need each SNP once
lapply(best, setkey, snp)
best <- lapply(best, unique)
mapply(set, best, j=paste0(data.types, "QTL"), value=TRUE)

lapply(best, set, j="q.value", value=NULL)
best <- Reduce(partial(merge, all=TRUE), best)

# now get all the data
data <- lapply(sprintf(data.file, data.types, data.use), fread, select=c("snp", "p.value"))

# keep only the SNPs we will use
data <- lapply(data, setkey, snp)
data <- lapply(data, "[", best)

# correct P-values for number of features tested per SNP
data <- lapply(data, "[", j=p.adjust(p.value, method="holm"), by=snp)
data <- lapply(data, setnames, "V1", "adj.p.value")

# set NA p-values to 1
na.rows <- lapply(data, "[", j=which(is.na(adj.p.value)))
mapply(set, data, i=na.rows, j=2L, value=1)

# get the lowest P-value per SNP
data <- lapply(data, setkey, snp, adj.p.value)
data <- lapply(data, setkey, snp)
data <- lapply(data, unique)

# get q-values
data <- lapply(data, "[", best)
names(data) <- data.types

# get overlaps
pairs <- expand.grid(data.types, data.types)
overlap <- apply(pairs, 1, function (x) {
    by.data <- data[[x[2]]]
    keep.rows <- which(by.data[[paste0(x[1], "QTL")]])
    if (x[1] == x[2])
        return(by.data[keep.rows,snp])
    keep.rows <- by.data[keep.rows, which(qvalue(adj.p.value)$qvalue < 0.05)]
    by.data[keep.rows, snp]
})

qtl.names <- paste0(data.types, "QTLs")
names(overlap) <- rep(qtl.names, each=length(qtl.names))

overlap.size <- matrix(sapply(overlap, length), nrow=length(data.types))
dimnames(overlap.size) <- list(qtl.names, qtl.names)
cat(kable(overlap.size, "markdown"), file=file.path("tables", "qtl_overlap.md"), sep="\n")

overlap.prop <- round(overlap.size*100/n.features)

pdf(file.path("plots", "qtl_overlap.pdf"), onefile=FALSE)
pheatmap(overlap.prop, cluster_rows=FALSE, cluster_cols=FALSE, 
         legend=FALSE, fontsize=18, fontsize_number=18, 
         display_numbers=TRUE, breaks=0:100,
         number_format="%.0f %%")
dev.off()
