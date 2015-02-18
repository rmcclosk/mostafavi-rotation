#!/usr/bin/env Rscript

library(knitr)
source(file="qtl.R")

tbl <- data.frame(patients=c(epatients, mpatients, apatients))
rownames(tbl) <- c("eQTL", "meQTL", "aceQTL")
tbl[,"features tested"] <- c(edata[,length(unique(feature))],
                             mdata[,length(unique(feature))],
                             adata[,length(unique(feature))])
tbl[,"SNPs tested"] <- c(edata[,length(unique(snp_position))],
                         mdata[,length(unique(snp_position))],
                         adata[,length(unique(snp_position))])
tbl[,"total tests done"] <- c(nrow(edata), 
                              nrow(mdata),
                              nrow(adata))
tbl[,"SNPs per feature"] <- c(median.iqr(edata[,length(snp_position),feature][,V1]),
                              median.iqr(mdata[,length(snp_position),feature][,V1]),
                              median.iqr(adata[,length(snp_position),feature][,V1]))
tbl[,"features per SNP"] <- c(median.iqr(edata[,length(feature), snp_position][,V1]),
                              median.iqr(mdata[,length(feature), snp_position][,V1]),
                              median.iqr(adata[,length(feature), snp_position][,V1]))
tbl[,"significant features"] <- c(edata.cor[,length(unique(feature))],
                                  mdata.cor[,length(unique(feature))],
                                  adata.cor[,length(unique(feature))])
tbl[,"significant QTLs per feature"] <- c(median.iqr(edata.cor[,length(snp_position),feature][,V1]),
                                          median.iqr(mdata.cor[,length(snp_position),feature][,V1]),
                                          median.iqr(adata.cor[,length(snp_position),feature][,V1]))
tbl[,"Spearman's rho"] <- c(median.iqr(edata.cor[,rho]),
                            median.iqr(mdata.cor[,rho]),
                            median.iqr(adata.cor[,rho]))
kable(t(tbl), "markdown")
