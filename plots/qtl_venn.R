#!/usr/bin/env Rscript

# basic information about QTLs

library(VennDiagram)
library(RColorBrewer)
library(RPostgreSQL)
library(qvalue)
library(data.table)
library(reshape2)

set.seed(0)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

do.get <- function (query) {
    data <- dbGetQuery(con, query)
    setDT(data)
    if (nrow(data) > 0)
        setkey(data, position)
    else
        NULL
}

equery <- paste("SELECT DISTINCT ON (e.gene_id) e.position,",
                "COALESCE(a.p_value, 1) AS p_value_1,",
                "COALESCE(m.p_value, 1) AS p_value_2",
                "FROM eqtl_chr%d e",
                "LEFT JOIN aceqtl_chr%d a",
                "ON a.snp_position = e.position",
                "LEFT JOIN meqtl_chr%d m",
                "ON m.snp_position = e.position",
                "WHERE e.q_value < 0.05",
                "ORDER BY e.gene_id, e.adj_p_value")

aquery <- paste("SELECT DISTINCT ON (a.peak_centre) a.snp_position AS position,",
                "COALESCE(e.p_value, 1) AS p_value_1,",
                "COALESCE(m.p_value, 1) AS p_value_2",
                "FROM aceqtl_chr%d a",
                "LEFT JOIN eqtl_chr%d e",
                "ON a.snp_position = e.position",
                "LEFT JOIN meqtl_chr%d m",
                "ON m.snp_position = a.snp_position",
                "WHERE a.q_value < 0.05",
                "ORDER BY a.peak_centre, a.adj_p_value")

mquery <- paste("SELECT DISTINCT ON (m.cpg_position) m.snp_position AS position,",
                "COALESCE(e.p_value, 1) AS p_value_1,",
                "COALESCE(a.p_value, 1) AS p_value_2",
                "FROM meqtl_chr%d m",
                "LEFT JOIN eqtl_chr%d e",
                "ON m.snp_position = e.position",
                "LEFT JOIN aceqtl_chr%d a",
                "ON m.snp_position = a.snp_position",
                "WHERE m.q_value < 0.05",
                "ORDER BY m.cpg_position, m.adj_p_value")

doit <- function (query, table, qtl.order) {
    data <- do.call(rbind, lapply(1:22, function (chr) {
        cat("Selecting", table, "from chromosome", chr, "... ")
        res <- unique(do.get(sprintf(query, chr, chr, chr)))
        cat("done\n")
        res
    }))
    data[,q_value_1 := qvalue(p_value_1)$qvalue]
    data[,q_value_2 := qvalue(p_value_2)$qvalue]

    area1 <- nrow(data)
    area2 <- sum(data[,q_value_1] < 0.05)
    area3 <- sum(data[,q_value_2] < 0.05)
    intersect <- sum(data[,q_value_2] < 0.05 & data[,q_value_1] < 0.05)
    
    png(paste0(table, "_venn.png"), height=240, width=240)
    draw.triple.venn(
        area1, area2, area3, area2, intersect, area3, intersect,
        category=qtl.order,
        col=brewer.pal(3, "Set2"),
        fill=brewer.pal(3, "Set2"),
        alpha=rep(0.3, 3)
    )
    dev.off()
}
    
#doit(equery, "eqtl", c("eQTLs", "aceQTLs", "meQTLs"))
doit(aquery, "aceqtl", c("aceQTLs", "eQTLs", "meQTLs"))
#doit(mquery, "meqtl", c("meQTLs", "eQTLs", "aceQTLs"))
dbDisconnect(con)
