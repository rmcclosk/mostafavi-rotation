#!/usr/bin/env Rscript

library(RPostgreSQL)

# definition 1, Janzing et al. 2014
may.cause <- function (x, y) {
    lhs <- sum(log(abs(diff(y[order(x)]))/abs(diff(x[order(x)]))))
    rhs <- sum(log(abs(diff(x[order(y)]))/abs(diff(y[order(y)]))))
    lhs < rhs
}
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
query <- paste("SELECT", paste(vars, collapse=", "), "FROM patient WHERE",
               paste(vars, collapse=" IS NOT NULL AND "), "IS NOT NULL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")
data <- dbGetQuery(con, query)
. <- dbDisconnect(con)

x <- range01(data$tangles_sqrt)
y <- range01(data$amyloid_sqrt)
z <- range01(-data$globcog_random_slope)

may.cause(x, y)
may.cause(y, z)
may.cause(x, z)
