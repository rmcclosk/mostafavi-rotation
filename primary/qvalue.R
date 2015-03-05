#!/usr/bin/env Rscript

# get the best QTLs for each feature

library(data.table)
library(qvalue)

dirs <- c("eQTL", "meQTL", "aceQTL")

sapply(dirs, function (dir) {
    files <- file.path(dir, paste0("chr", 1:22, ".tsv"))
    
    # read data
    data <- rbindlist(lapply(files, fread))
    
    # adjust p-values for each gene separately
    data[,adj.p.value := p.adjust(p.value, method="holm"), by="feature"]
    data[,adj.p.value.nocov := p.adjust(p.value.nocov, method="holm"), by="feature"]

    # calculate q-values per gene
    snp.counts <- data[,length(snp), feature][,V1]

    min.p.value <- data[,min(adj.p.value), feature][,V1]
    data[,q.value := rep(qvalue(min.p.value, robust=TRUE)$qvalue, snp.counts)]

    min.p.value.nocov <- data[,min(adj.p.value.nocov), feature][,V1]
    data[,q.value.nocov := rep(qvalue(min.p.value.nocov, robust=TRUE)$qvalue, snp.counts)]

    # take only the best SNP per gene
    setkey(data, feature, adj.p.value)
    dcov <- data[,.SD[1], feature]

    setkey(data, feature, adj.p.value.nocov)
    dnocov <- data[,.SD[1], feature]

    # combine best SNPS for covariates and no covariates
    data <- unique(setkey(rbind(dcov, dnocov), feature, snp))
    write.table(data, paste0(dir, "/best.tsv"), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
})
