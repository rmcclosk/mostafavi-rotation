#!/usr/bin/env Rscript

library(RSQLite)
library(deal)

con <- dbConnect(SQLite(), "../data/db-pheno.sqlite")

do.select <- function (con, query) {
    res <- dbSendQuery(con, query)
    data <- dbFetch(res)
    dbClearResult(res)
    data
}

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope", "pathoAD",
          "pmAD")
query <- paste("SELECT", paste(vars, collapse=", "), "FROM patient")
data <- do.select(con, query)
data <- na.omit(data)
data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

# mixed continuous and discrete, exhaustive search
net <- network(data)
prior <- jointprior(net)
net <- learn(net, data, prior)$nw
all.nets <- networkfamily(data, net, prior)
all.nets <- nwfsort(all.nets$nw)
best.nets <- all.nets[sapply(all.nets, "[[", "relscore") == 1]

pdf("deal.pdf")
sapply(best.nets, plot)
dev.off()

. <- dbDisconnect(con)
