#!/usr/bin/env Rscript

library(RSQLite)
library(ggplot2)
library(GGally)

vars <- c("tangles_sqrt", 
          "amyloid_sqrt",
          "globcog_random_slope",
          "pathoAD", 
          "pmAD")

con <- dbConnect(SQLite(), "../data/db.sqlite")
query <- paste("SELECT", paste(vars, collapse=","), "FROM patient")
res <- dbSendQuery(con, query)
data <- dbFetch(res)
. <- dbClearResult(res)
. <- dbDisconnect(con)

data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

pdf("phenotypes.pdf")
ggpairs(na.omit(data))
ggplot(data, aes(x=tangles_sqrt)) + geom_density()
ggplot(data, aes(x=amyloid_sqrt)) + geom_density()
ggplot(data, aes(x=globcog_random_slope)) + geom_density()
dev.off()
