#!/usr/bin/env Rscript

# Insert adjusted P-values and Q-values into database

library(qvalue)
library(RPostgreSQL)
library(data.table)

do.get <- function (query) {
    data <- dbGetQuery(con, query)
    setDT(data)
    setkey(data, chrom, feature)
    data
}

do.adjust <- function (data) {
    data[,adj_p_value := p.adjust(p_value, method="holm"), "chrom,feature"]
    qval.data <- data[,min(adj_p_value),"chrom,feature"][,q_value := qvalue(V1)$qvalue]
    data <- merge(data, qval.data)
    data[,V1 := NULL]
    data
}

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

cat("Correcting eQTLs... ")
equery <- "SELECT chrom, gene_id AS feature, position, rho, p_value FROM eqtl"
edata <- do.adjust(do.get(equery))
write.table(edata, file="db/eqtl.tsv", sep="\t", row.names=F, col.names=F, quote=F)

cat("done\nCorrecting aceQTLs... ")
aquery <- "SELECT chrom, peak_centre AS feature, snp_position AS position, p_value FROM aceqtl"
adata <- do.adjust(do.get(aquery))
write.table(adata, file="db/aceqtl.tsv", sep="\t", row.names=F, col.names=F, quote=F)

cat("done\nCorrecting meQTLs... ")
mquery <- "SELECT chrom, cpg_position AS feature, snp_position AS position, p_value FROM meqtl"
mdata <- do.adjust(do.get(mquery))
write.table(adata, file="db/meeqtl.tsv", sep="\t", row.names=F, col.names=F, quote=F)
cat("done\n")

dbDisconnect(con)
