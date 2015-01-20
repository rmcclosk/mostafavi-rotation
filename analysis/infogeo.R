#!/usr/bin/env Rscript

library(RSQLite)

# definition 1, Janzing et al. 2014
may.cause <- function (x, y) {
    lhs <- sum(log(abs(diff(y[order(x)]))/abs(diff(x[order(x)]))))
    rhs <- sum(log(abs(diff(x[order(y)]))/abs(diff(y[order(y)]))))
    lhs < rhs
}
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

vars <- c("tangles_sqrt", "amyloid_sqrt")

con <- dbConnect(SQLite(), "../data/db.sqlite")
query <- paste("SELECT", paste(vars, collapse=","), "FROM patient")
res <- dbSendQuery(con, query)
data <- dbFetch(res)
. <- dbClearResult(res)
. <- dbDisconnect(con)

data <- na.omit(data)
x <- range01(data$tangles_sqrt)
y <- range01(data$amyloid_sqrt)
may.cause(x, y)
