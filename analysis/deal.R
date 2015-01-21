#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(RSQLite)
library(deal)

set.seed(0)

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

png("deal.png")
sapply(best.nets, plot)
dev.off()

. <- dbDisconnect(con)
