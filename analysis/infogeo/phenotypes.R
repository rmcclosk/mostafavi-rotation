#!/usr/bin/env Rscript

# use information-geometric causal inference to check out phenotype
# relationships

# definition 1, Janzing et al. 2014
may.cause <- function (x, y) {
    lhs <- sum(log(abs(diff(y[order(x)]))/abs(diff(x[order(x)]))))
    rhs <- sum(log(abs(diff(x[order(y)]))/abs(diff(y[order(y)]))))
    lhs < rhs
}
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

vars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
data <- read.csv("../../data/pheno_cov_n2963_092014_forPLINK.csv", na.strings=c("-9"))
data <- data[,vars]
data[which(data == 0, arr.ind=TRUE)] <- NA
data <- na.omit(data)

x <- range01(data$tangles_sqrt)
y <- range01(data$amyloid_sqrt)
z <- range01(-data$globcog_random_slope)

may.cause(x, y)
may.cause(y, z)
may.cause(x, z)
