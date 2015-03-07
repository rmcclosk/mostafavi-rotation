#!/usr/bin/env Rscript

# get the best QTLs for each feature

library(data.table)
library(qvalue)

#dirs <- c("eQTL", "meQTL", "aceQTL")
dirs <- c("eQTL")

sapply(dirs, function (dir) {
    files <- file.path(dir, paste0("chr", 1:22, ".tsv"))
    
    # read data
    data <- rbindlist(lapply(files, fread))
    setkey(data, feature, snp)
    snp.counts <- data[,length(snp), feature][,V1]
    
    # adjust p-values for each gene separately
    data.types <- c("", ".nocov")
    data.types <- c(data.types, paste0(".PC", 1:20))
    sapply(data.types, function (x) {
        setnames(data, paste0("p.value", x), "p")
        data[,adj.p := p.adjust(p, method="holm"), by=feature]

        # calculate q-values per gene
        min.p.value <- data[,min(adj.p), by=feature][,V1]
        data[,q := rep(qvalue(min.p.value, robust=TRUE)$qvalue, snp.counts)]

        setnames(data, "adj.p", paste0("adj.p.value", x))
        setnames(data, "q", paste0("q.value", x))
        setnames(data, "p", paste0("p.value", x))
    })

    # take only the best SNP per gene
    data <- rbindlist(lapply(data.types, function (x) {
        setkeyv(data, c("feature", paste0("adj.p.value", x)))
        data[,.SD[1], feature]
    }))

    # combine best SNPs
    data <- unique(setkey(data, feature, snp))
    write.table(data, paste0(dir, "/best.tsv"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
})
