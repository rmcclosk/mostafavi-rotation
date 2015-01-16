#!/usr/bin/env Rscript

library(RSQLite)
library(GGally)

vars <- c("tangles_sqrt", 
          "amyloid_sqrt",
          "globcog_random_slope",
          "pathoAD", 
          "pmAD")

con <- dbConnect(SQLite(), "../data/db.sqlite")
query <- paste("SELECT", paste(vars, collapse=","), "FROM phenotype")
res <- dbSendQuery(con, query)
data <- dbFetch(res)

data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

. <- dbClearResult(res)

pdf("phenotypes.pdf")
ggpairs(na.omit(data))
dev.off()

. <- dbDisconnect(con)
