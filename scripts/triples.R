#!/usr/bin/env Rscript

# Find all the gene/CpG/peak triples found by all pairwise analyses.

library(data.table)

data.types <- c("e", "ace", "me")
files <- outer(data.types, data.types, paste, sep="_")
files <- paste0(setdiff(c(files), diag(files)), ".tsv")
files <- file.path("results", "pairs", files)

feature.cols <- paste0("feature.", data.types)
feature.cols <- expand.grid(feature.cols, feature.cols)
feature.cols <- as.list(as.data.frame(t(subset(feature.cols, Var1 != Var2)), stringsAsFactors=FALSE))

data <- mapply(fread, files, select=lapply(feature.cols, c, "q.value"), SIMPLIFY=FALSE)
data <- lapply(data, "[", i=q.value < 0.05)
data <- mapply("[", data, j=feature.cols, with=FALSE, SIMPLIFY=FALSE)
mapply(setkeyv, data, feature.cols)

feature.cols <- unique(unlist(feature.cols))
data <- Reduce(function (x, y) setkeyv(merge(x, y), feature.cols), data)

# get non-redundant triples only
col.order <- order(apply(data, 2, function (x) length(unique(x))))
sapply(col.order, function (i) {
    data <<- unique(setkeyv(data, colnames(data)[i]))
})

write.table(data, file.path("results", "triples.tsv"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
