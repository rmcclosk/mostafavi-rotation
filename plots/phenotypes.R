#!/usr/bin/env Rscript

library(ggplot2)
library(GGally)

cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
dvars <- c("pathoAD", "pmAD")
data <- read.csv("../data/pheno_cov_n2963_092014_forPLINK.csv", na.strings=c("-9"))
data <- data[,c(cvars, dvars)]

data[which(data[,cvars] == 0, arr.ind=TRUE)] <- NA
data[,dvars] <- lapply(data[,dvars], ordered, levels=c(0, 1))
data <- na.omit(data)
head(data)

png("phenotypes.png")
ggpairs(data)
dev.off()

. <- sapply(cvars, function (v) {
    png(sprintf("phenotypes/%s.png", v))
    print(ggplot(data, aes_string(x=v)) + geom_density())
    dev.off()
})
