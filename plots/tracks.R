#!/usr/bin/env Rscript

library(RSQLite)

con <- dbConnect(SQLite(), "../data/db.sqlite")

do.select <- function (con, query) {
    res <- dbSendQuery(con, query)
    data <- dbFetch(res)
    dbClearResult(res)
    data
}

a.query <- paste("SELECT a.ProjectID, p.Chr, p.Start, p.End, a.value",
                 "FROM acetylation a JOIN acetylationPeaks p",
                 "ON p.Peak = a.Peak")
a.data <- do.fetch(con, a.query)

e.query <- paste("SELECT e.ProjectID, g.chrom, g.txStart, g.txEnd, e.value",
                 "FROM expression e JOIN ensGene g",
                 "ON e.ensembl_id = g.name2")
e.data <- do.fetch(con, e.query)
. <- dbDisconnect(con)

plot.ids <- intersect(levels(a.data$ProjectID), levels(e.data$ProjectID))

id <- plot.ids[1]
pdf("tracks.pdf")
dev.off()
