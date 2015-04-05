#!/usr/bin/env Rscript

# get the best QTLs for each feature

library(data.table)
library(qvalue)

dir <- commandArgs(trailingOnly=TRUE)[2]
dir <- gsub("/", "", dir)
if (!dir %in% c("eQTL", "meQTL", "aceQTL")) {
    cat("Wrong argument\n", stderr())
    quit()
}

data.types <- c("PC0.nocov", paste0("PC", 0:20))

files <- file.path(dir, paste0(data.types, ".tsv"))
files <- files[file.exists(files)]

# read data
lapply(files, function (f) {
    cat("Processing file", f, "\n")
    
    data <- fread(f)
    setkey(data, feature, p.value)
    
    # adjust p-values for each feature separately
    data[,adj.p.value := p.adjust(p.value, method="holm"), by=feature]

    # take only the best SNP per feature
    data <- data[,.SD[1], feature]

    # calculate q-values per feature
    min.p.value <- data[,min(adj.p.value), by=feature][,V1]
    data[,q.value := qvalue(min.p.value, robust=TRUE)$qvalue]

    outfile <- sub(".tsv", ".best.tsv", f)
    write.table(data, outfile, row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
    rm(data)
    gc()
})
