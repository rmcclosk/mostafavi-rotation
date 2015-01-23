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
query <- paste("SELECT", paste(vars, collapse=", "), "FROM patient WHERE",
               paste(vars, collapse=" IS NOT NULL AND "), "IS NOT NULL")
data <- dbGetQuery(con, query)
. <- dbDisconnect(con)

data$pathoAD <- factor(data$pathoAD)
data$pmAD <- factor(data$pmAD)

png("phenotypes.png")
ggpairs(data)
dev.off()

. <- sapply(vars[1:3], function (v) {
    png(sprintf("phenotypes/%s.png", v))
    print(ggplot(data, aes_string(x=v)) + geom_density())
    dev.off()
})
