#!/usr/bin/env Rscript

# Estimate a Bayesian network on gene modules and phenotypes with the deal
# package.

library(data.table)
library(tools)

source(file=file.path("utils", "deal.R"))

# store temporary results in a cache file named out of a hash of the input data
checksum <- substr(md5sum(file.path("data", "module_means_filtered_byphenotype.txt")), 1, 6)
cache.file <- file.path("cache", paste0("deal_modules_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    # the heuristic search is random, so set a seed for reproducibility
    set.seed(0)
    
    # define the continuous and discrete variables we are using
    cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
    dvars <- c("pathoAD", "pmAD")

    # read the data, including all patients, not just those with all four data
    # types
    # keep complete cases only
    p.data <- read.table(file.path("data", "patients.tsv"), header=TRUE)
    p.data <- na.omit(p.data[,c("projid", cvars, dvars)])
    
    # make ordered factors out of the discrete variables
    p.data[,dvars] <- lapply(p.data[,dvars], ordered, levels=c(0, 1))
    
    # read the mean expression levels for each module
    e.data <- fread(file.path("data", "module_means_filtered_byphenotype.txt"))
    e.data[,V1 := as.integer(sub(":.*", "", V1))]
    setnames(e.data, "V1", "projid")
    setDF(e.data)
    
    # combine the phenotype and module expression data
    data <- merge(e.data, p.data)
    data$projid <- NULL
    
    # use deal to find the best network
    best.net <- best.net.heuristic(data)
    save(best.net, file=cache.file)
} else {
    load(cache.file)
}

# plot the best network
pdf(file.path("plots", "deal_modules.pdf"))
plot.net.graphviz(best.net, 
                  edge.attrs=list(arrowhead="open"),
                  node.attrs=list(shape="ellipse", fontsize="14", fixedsize="false", margin="0.66,0.22"))
dev.off()
