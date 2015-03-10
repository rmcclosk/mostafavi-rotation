#!/usr/bin/env Rscript

# just get some basic details about the different QTL types

library(data.table)
library(knitr)

median.iqr <- function (x) {
    sprintf("%.2g [%.2g-%.2g]", median(x), quantile(x, 0.25), quantile(x, 0.75))
}

#efile <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
#afile <- "../data/chipSeqResiduals.csv"
#mfile <- "../data/ill450kMeth_all_740_imputed.txt"
#pfile <- "../data/phenotype_740qc_finalFromLori.txt"
#gfile <- "../data/transposed_1kG/chr1/chr1.560001.560059.snplist.test.snps.dosage.1kg.trans.txt"
#
#id.map <- fread(pfile, select=c("Sample_ID", "projid"), 
#                colClasses=list(character="projid"))
#setkey(id.map, Sample_ID)
#
#epatients <- fread(efile, select=1)[,gsub(":.*", "", V1)]
#apatients <- colnames(fread(afile, nrows=0, skip=0))
#mpatients <- colnames(fread(mfile, nrows=0, skip=0))
#mpatients <- id.map[mpatients[2:length(mpatients)],projid]
#
#gpatients <- fread(gfile, skip=1, select=1)[,gsub("[A-Z]", "", V1)]
#epatients <- as.character(length(intersect(epatients, gpatients)))
#apatients <- as.character(length(intersect(apatients, gpatients)))
#mpatients <- as.character(length(intersect(mpatients, gpatients)))
#
#tbl <- data.frame(eQTL=epatients, meQTL=mpatients, aceQTL=apatients)
#rownames(tbl) <- c("patients")
#
#edata <- rbindlist(lapply(paste0("eQTL/chr", 1:22, ".tsv"), fread))
#mdata <- rbindlist(lapply(paste0("meQTL/chr", 1:22, ".tsv"), fread))
#adata <- rbindlist(lapply(paste0("aceQTL/chr", 1:22, ".tsv"), fread))
#
#raw.stats <- function (data) {
#    c(`features tested`=data[,length(unique(feature))],
#      `SNPs tested`=data[,length(unique(snp))],
#      `total tests done`=nrow(data),
#      `SNPs per feature`=median.iqr(data[,length(snp),by=feature][,V1]),
#      `features per SNP`=median.iqr(data[,length(feature),by=snp][,V1]))
#}
#data <- list(edata, mdata, adata)
#raw.data <- do.call(cbind, lapply(data, raw.stats))
#colnames(raw.data) <- c("eQTL", "meQTL", "aceQTL")
#tbl <- rbind(tbl, raw.data)
#
#rm(data)
#rm(edata)
#rm(mdata)
#rm(adata)
#gc()

ebest <- fread("eQTL/best.tsv")
mbest <- fread("meQTL/best.tsv")
abest <- fread("aceQTL/best.tsv")

best.stats <- function (data) {
    setkey(data, feature, adj.p.value)
    dcov <- data[,.SD[1], feature]
    stopifnot(nrow(dcov) == length(unique(data[,feature])))

    setkey(data, feature, adj.p.value.nocov)
    dnocov <- data[,.SD[1], feature]
    stopifnot(nrow(dnocov) == length(unique(data[,feature])))

    c(`significant features`=dcov[,sum(q.value < 0.05)],
      `Spearman's rho`=median.iqr(dcov[q.value < 0.05, rho]),
      `significant features (no cov.)`=dnocov[,sum(q.value.nocov < 0.05)],
      `Spearman's rho (no cov.)`=median.iqr(dnocov[q.value.nocov < 0.05, rho.nocov]))
}
data <- list(ebest, mbest, abest)
best.data <- do.call(cbind, lapply(data, best.stats))
colnames(best.data) <- c("eQTL", "meQTL", "aceQTL")
kable(best.data, "markdown")
#tbl <- rbind(tbl, best.data)
#kable(tbl, "markdown")
