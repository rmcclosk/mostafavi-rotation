#!/usr/bin/env Rscript

library(RSQLite)
library(ggplot2)
library(GGally)

vars <- c("tangles_sqrt", 
          "amyloid_sqrt",
          "globcog_random_slope",
          "pathoAD", 
          "pmAD")

con <- dbConnect(SQLite(), "../data/db-pheno.sqlite")
query <- paste("SELECT", paste(vars, collapse=","), "FROM patient")
res <- dbSendQuery(con, query)
data <- dbFetch(res)
. <- dbClearResult(res)
. <- dbDisconnect(con)

data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

pdf("phenotypes.png")
ggpairs(na.omit(data))
dev.off()

. <- sapply(vars[1:3], function (v) {
    png(sprintf("phenotypes/%s.png", v))
    print(ggplot(data, aes_string(x=v)) + geom_density())
    dev.off()
})
