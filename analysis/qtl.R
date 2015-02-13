#!/usr/bin/env Rscript

# basic information about QTLs

library(RPostgreSQL)
library(qvalue)
library(data.table)

set.seed(0)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

cat("Selecting eQTLs... ")
equery <- paste("SELECT chrom, gene_id AS feature, position AS snp_position, rho, p_value FROM eqtl ORDER BY gene_id, position")
edata <- as.data.table(dbGetQuery(con, equery))
setkey(edata, chrom, feature)
cat("done\n")

cat("Selecting aceQTLs... ")
aquery <- paste("SELECT chrom, peak_centre AS feature, snp_position, rho, p_value FROM aceqtl ORDER BY peak_centre, snp_position")
adata <- as.data.table(dbGetQuery(con, aquery))
setkey(adata, chrom, feature)
cat("done\n")

cat("Selecting meQTLs... ")
mquery <- paste("SELECT chrom, cpg_position AS feature, snp_position, rho, p_value FROM meqtl ORDER BY cpg_position, snp_position")
mdata <- dbGetQuery(con, mquery)
setDT(mdata)
setkey(mdata, chrom, feature)
cat("done\n")

mquery <- paste("SELECT COUNT(DISTINCT patient_id) FROM methylation_chr22")
mpatients <- dbGetQuery(con, mquery)[1,1]

aquery <- paste("SELECT COUNT(DISTINCT patient_id) FROM acetylation_chr22")
apatients <- dbGetQuery(con, aquery)[1,1]

equery <- paste("SELECT COUNT(DISTINCT patient_id) FROM expression_chr22")
epatients <- dbGetQuery(con, equery)[1,1]

dbDisconnect(con)

# do P-value correction on QTLs and return only the significant QTLs
correct.qtls <- function (data) {
    data <- data[,adj.p.value := p.adjust(p_value, method="holm"), "chrom,feature"]
    qval.data <- data[,min(adj.p.value),"chrom,feature"][,q.value := qvalue(V1)$qvalue]
    data <- merge(data, qval.data)
    subset(data, q.value < 0.05 & adj.p.value < 0.05)
}

median.iqr <- function (x) {
    sprintf("%.2g [%.2g-%.2g]", median(x), quantile(x, 0.25), quantile(x, 0.75))
}

cat("Correcting eQTLs... ")
edata.cor <- correct.qtls(edata)
cat("done\nCorrecting meQTLs... ")
mdata.cor <- correct.qtls(mdata)
cat("done\nCorrecting aceQTLs... ")
adata.cor <- correct.qtls(adata)
cat("done\n")
