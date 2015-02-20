#!/usr/bin/env Rscript

# Insert adjusted P-values and Q-values into database

library(qvalue)
library(RPostgreSQL)
library(data.table)

tfile <- tempfile()

get.dt <- function (query) 
    setkey(setDT(dbGetQuery(con, query)), chrom, feature)

do.adjust <- function (query, table) {
    data <- get.dt(query)
    data[,adj_p_value := p.adjust(p_value, method="holm"), "chrom,feature"]
    qval.data <- data[,min(adj_p_value),"chrom,feature"][,q_value := qvalue(V1)$qvalue]
    data <- merge(data, qval.data)[,V1 := NULL]

    write.table(data, file=tfile, sep="\t", row.names=F, col.names=F, quote=F)
    dbGetQuery(con, "BEGIN TRANSACTION")
    tryCatch({
        dbGetQuery(con, paste("DELETE FROM", table))
        dbGetQuery(con, sprintf("COPY %s FROM '%s'", table, tfile))
        dbCommit(con)
    }, error = function (e) {
        dbRollback(con)
    })
}

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

equery <- "SELECT chrom, gene_id AS feature, position, rho, p_value FROM eqtl"
aquery <- "SELECT chrom, peak_centre AS feature, snp_position AS position, rho, p_value FROM aceqtl"
mquery <- "SELECT chrom, cpg_position AS feature, snp_position AS position, rho, p_value FROM meqtl"

do.adjust(equery, "eqtl")
do.adjust(aquery, "aceqtl")
do.adjust(mquery, "meqtl")

dbDisconnect(con)
