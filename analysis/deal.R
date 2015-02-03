#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(RPostgreSQL)
library(deal)

nice.dim <- function (n) {
    w <- round(sqrt(n))
    while (n %% w != 0) w <- w+1
    w
}

set.seed(0)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope", "pathoAD",
          "pmAD")
query <- paste("SELECT", paste(vars, collapse=", "), "FROM patient WHERE",
               paste(vars, collapse=" IS NOT NULL AND "), "IS NOT NULL")
data <- dbGetQuery(con, query)
data$pathoad <- factor(data$pathoad)
data$pmad <- factor(data$pmad)
dbDisconnect(con)

# mixed continuous and discrete, exhaustive search
net <- network(data)
prior <- jointprior(net)
net <- learn(net, data, prior)$nw
all.nets <- networkfamily(data, net, prior)
all.nets <- nwfsort(all.nets$nw)

scores <- sapply(all.nets, "[[", "score")
relscores <- sapply(all.nets, "[[", "relscore")
best.nets <- all.nets[sapply(relscores, all.equal, 1) == "TRUE"]
head(cbind(scores, relscores))

w <- nice.dim(length(best.nets))
h <- length(best.nets)/w

png("deal.png", width=480*w, height=480*h)
par(mfrow=c(w, h), mar=c(0, 0, 0, 0))
sapply(best.nets, plot)
dev.off()
