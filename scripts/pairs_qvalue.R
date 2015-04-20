#!/usr/bin/env Rscript

library(qvalue)
library(data.table)

data.types <- commandArgs(trailingOnly=TRUE)[2:3]
if (!all(data.types %in% c("e", "me", "ace")))
    stop("Wrong arguments")

cor.file <- paste(c(sort(data.types), "pairs.tsv"), collapse="_")
cor.file <- file.path("results", cor.file)

feature.vars <- paste0("feature.", data.types)
data <- fread(cor.file)

# adjust P-values of second data type
data[,adj.p.value := p.adjust(p.value, method="holm"), by=eval(feature.vars[1])]

# take best P-value for each feature of first data type
setkeyv(data, c(feature.vars[1], "adj.p.value"))
data <- data[,.SD[1], by=eval(feature.vars[1])]

# q-value
data[,q.value := qvalue(adj.p.value)$qvalue]

outfile <- do.call(sprintf, as.list(c("%s_%s.tsv", data.types)))
outfile <- file.path("results", "pairs", outfile)
write.table(data, outfile, col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
