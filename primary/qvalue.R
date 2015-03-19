#!/usr/bin/env Rscript

# get the best QTLs for each feature

library(data.table)
library(qvalue)
library(parallel)

dir <- commandArgs(trailingOnly=TRUE)[2]
dir <- gsub("/", "", dir)
if (!dir %in% c("eQTL", "meQTL", "aceQTL")) {
    cat("Wrong argument\n", stderr())
    quit()
}

data.types <- c("", ".nocov", paste0(".PC", 1:20))

files <- file.path(dir, paste0("chr", 1:22, ".tsv"))

## read data
#lapply(files, function (f) {
#    data <- fread(f)
#    setkey(data, feature, snp)
#    
#    # adjust p-values for each feature separately
#    sapply(data.types, function (x) {
#        setnames(data, paste0("p.value", x), "p")
#        data[,adj.p := p.adjust(p, method="holm"), by=feature]
#
#        setnames(data, "adj.p", paste0("adj.p.value", x))
#        setnames(data, "p", paste0("p.value", x))
#    })
#
#    # take only the best SNP per feature
#    res <- rbindlist(lapply(data.types, function (x) {
#        setkeyv(data, c("feature", paste0("adj.p.value", x)))
#        data[,.SD[1], feature]
#    }))
#    write.table(res, paste0(f, ".qvalue"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
#    rm(data)
#    rm(res)
#    gc()
#})
#
#gc()
drops <- c(paste0("p.value", data.types), paste0("t.stat", data.types))
data <- rbindlist(lapply(paste0(files, ".qvalue"), fread, drop=drops))

setkey(data, feature)
snp.counts <- data[,length(snp), feature][,V1]

# calculate q-values per feature
sapply(data.types, function (x) {
    setnames(data, paste0("adj.p.value", x), "adj.p")

    min.p.value <- data[,min(adj.p), by=feature][,V1]
    data[,q := rep(qvalue(min.p.value, robust=TRUE)$qvalue, snp.counts)]

    setnames(data, "q", paste0("q.value", x))
    setnames(data, "adj.p", paste0("adj.p.value", x))
    NULL
})

# combine best SNPs
data <- unique(setkey(data, feature, snp))
write.table(data, paste0(dir, "/best.tsv"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
