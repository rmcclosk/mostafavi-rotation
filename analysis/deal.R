#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(RSQLite)
library(deal)

set.seed(0)

con <- dbConnect(SQLite(), "../data/db-pheno.sqlite")

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope", "pathoAD",
          "pmAD")
query <- paste("SELECT", paste(vars, collapse=", "), "FROM patient WHERE",
               paste(vars, collapse=" IS NOT NULL AND "), "IS NOT NULL")
data <- dbGetQuery(con, query)
data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

# mixed continuous and discrete, exhaustive search
net <- network(data)
prior <- jointprior(net)
net <- learn(net, data, prior)$nw
all.nets <- networkfamily(data, net, prior)
all.nets <- nwfsort(all.nets$nw)
best.nets <- all.nets[sapply(all.nets, "[[", "relscore") == 1]

png("deal.png", width=960, height=480)
par(mfrow=c(1, 2), mar=c(0, 0, 0, 0))
sapply(best.nets, plot)
dev.off()

. <- dbDisconnect(con)
