#!/usr/bin/env Rscript

# Bayesian network on gene modules with the deal package.

library(data.table)
library(deal)
library(tools)

source(file=file.path("utils", "deal.R"))
checksum <- substr(md5sum(file.path("data", "module_means_filtered_byphenotype.txt")), 1, 6)
cache.file <- file.path("cache", paste0("deal_modules_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    set.seed(0)
    
    cvars <- c("tangles_sqrt", "amyloid_sqrt", "globcog_random_slope")
    dvars <- c("pathoAD", "pmAD")
    p.data <- read.table(file.path("data", "patients.tsv"), header=TRUE)
    p.data <- p.data[,c("projid", cvars, dvars)]
    
    p.data[which(p.data[,cvars] == 0, arr.ind=TRUE)] <- NA
    p.data[,dvars] <- lapply(p.data[,dvars], ordered, levels=c(0, 1))
    p.data <- na.omit(p.data)
    
    e.data <- fread(file.path("data", "module_means_filtered_byphenotype.txt"))
    e.data[,V1 := as.integer(sub(":.*", "", V1))]
    setnames(e.data, "V1", "projid")
    setDF(e.data)
    
    data <- merge(e.data, p.data)
    data$projid <- NULL
    
    best.net <- best.net.heuristic(data)
    save(best.net, file=cache.file)
} else {
    load(cache.file)
}

pdf(file.path("plots", "deal_modules.pdf"))
plot.net.graphviz(best.net, 
                  edge.attrs=list(arrowhead="open"),
                  node.attrs=list(shape="ellipse", fontsize="14", fixedsize="false", margin="0.66,0.22"))
dev.off()
