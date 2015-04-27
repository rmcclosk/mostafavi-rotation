#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(tools)
source(file=file.path("utils", "deal.R"))

set.seed(0)

nice.dim <- function (n) {
    w <- round(sqrt(n))
    while (n %% w != 0) w <- w+1
    w
}

checksum <- substr(md5sum(file.path("data", "patients.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_phenotypes_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
    dvars <- c("pathoAD", "pmAD")
    data <- read.table(file.path("data", "patients.tsv"), header=TRUE)
    data <- data[,c(cvars, dvars)]
    
    data[which(data[,cvars] == 0, arr.ind=TRUE)] <- NA
    data[,dvars] <- lapply(data[,dvars], ordered, levels=c(0, 1))
    data <- na.omit(data)
    
    # mixed continuous and discrete, exhaustive search
    best.nets <- best.nets.exhaustive(data)
    save(best.nets, file=cache.file)
} else {
    load(cache.file)
}

best.nets <- unique(best.nets)
h <- nice.dim(length(best.nets))
w <- length(best.nets)/h

pdf(file.path("plots", "deal_phenotypes.pdf"), width=4*w, height=4*h)
par(mfrow=c(h, w))
sapply(best.nets, plot.net.graphviz,
                  engine="circo",
                  edge.attrs=list(arrowhead="open"),
                  node.attrs=list(shape="ellipse", fontsize="12", fixedsize="false", margin="0.66,0.22"))
dev.off()
