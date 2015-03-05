#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(deal)
source(file="deal.R")

set.seed(0)

nice.dim <- function (n) {
    w <- round(sqrt(n))
    while (n %% w != 0) w <- w+1
    w
}

cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
dvars <- c("pathoAD", "pmAD")
data <- read.csv("../../data/pheno_cov_n2963_092014_forPLINK.csv", na.strings=c("-9"))
data <- data[,c(cvars, dvars)]

data[which(data[,cvars] == 0, arr.ind=TRUE)] <- NA
data[,dvars] <- lapply(data[,dvars], ordered, levels=c(0, 1))
data <- na.omit(data)

# mixed continuous and discrete, exhaustive search
best.nets <- best.nets.exhaustive(data)

w <- nice.dim(length(best.nets))
h <- length(best.nets)/w

png("phenotypes.png", width=480*w, height=480*h)
par(mfrow=c(w, h), mar=c(0, 0, 0, 0))
sapply(best.nets, plot)
dev.off()
