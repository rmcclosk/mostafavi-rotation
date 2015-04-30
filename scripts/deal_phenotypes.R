#!/usr/bin/env Rscript

# Estimate a Bayesian network of five important Alzheimer's phenotypes with the
# deal package.

library(tools)
source(file=file.path("utils", "deal.R"))

# because there will be more than one best network, this function finds a
# number of rows to display them all in a nice way, ie. as close to square as
# possible
nice.dim <- function (n) {
    h <- round(sqrt(n))
    while (n %% h != 0) h <- h+1
    h
}

# cache data in a file named out of a hash of the input data
checksum <- substr(md5sum(file.path("data", "patients.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("deal_phenotypes_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {

    # which continuous and discrete variables we are using
    cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
    dvars <- c("pathoAD", "pmAD")

    # read the data, keep complete cases only
    data <- read.table(file.path("data", "patients.tsv"), header=TRUE)
    data <- na.omit(data[,c(cvars, dvars)])
    
    # make ordered factors of the discrete variables
    data[,dvars] <- lapply(data[,dvars], ordered, levels=c(0, 1))
    data <- na.omit(data)
    
    # exhaustively search all networks and choose the best ones
    best.nets <- unique(best.nets.exhaustive(data))
    save(best.nets, file=cache.file)
} else {
    load(cache.file)
}

# get dimensions for plotting
h <- nice.dim(length(best.nets))
w <- length(best.nets)/h

# plot the best networks
pdf(file.path("plots", "deal_phenotypes.pdf"), width=4*w, height=4*h)
par(mfrow=c(h, w))
sapply(best.nets, plot.net.graphviz,
                  engine="circo",
                  edge.attrs=list(arrowhead="open"),
                  node.attrs=list(shape="ellipse", fontsize="12", fixedsize="false", margin="0.66,0.22"))
dev.off()
