#!/usr/bin/env Rscript

# Apply to the QTL data the causality test from this paper:
# Millstein, Joshua, et al.  "Disentangling molecular relationships with a
# causal inference test." BMC genetics 10.1 (2009): 23.
#
# TODO: there needs to be multiple test correction. The CausalityTestJM
# function returns 3 values: a P-value for the causal model, one for the
# reactive model, and a call, which is based on a P=0.05 cutoff. See
# utils/cit.R, and the paper, for more details. Currently I'm just reporting
# the call without correcting for the number of tests done.

library(data.table)
library(tools)
library(ggplot2)
library(reshape2)
source(file.path("utils", "cit.R"))

# make the cache file name by hashing the input data
checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("cit_qtl_", checksum, ".Rdata"))

data.types <- c("e", "ace", "me")
data.types.long <- c("expression", "acetylation", "methylation")

# list all mediator/phenotype pairs to be tested
tests <- setDT(expand.grid(mediator=data.types, phenotype=data.types, stringsAsFactors=FALSE))
tests <- tests[mediator != phenotype]

# a function to run the causality test and return the calls
# mediator and phenotype are the names of columns in data (can be vectors)
# data has the column "g" (for genotype)
do.test <- function (data, mediator, phenotype)
    do.call(CausalityTestJM, unname(as.list(data[,c("g", mediator, phenotype), with=FALSE])))[3]
do.test <- Vectorize(do.test, c("mediator", "phenotype"))

if (!file.exists(cache.file)) {

    # load the data
    data <- fread(file.path("results", "multi_qtl_data.tsv"))

    # run all the causal inference tests, using the above function
    data <- data[, cbind(tests, with(tests, do.test(.SD, mediator, phenotype))), snp]
    setnames(data, "V2", "model")
    save(data, file=cache.file)
} else {
    load(cache.file)
}

# use descriptions instead of integers for the test calls (see utils/cit.R)
model.types <- c("no call", "causal", "reactive", "indep./other")
data[,model := model.types[model+1]]
data[,model := factor(model, levels=model.types)]

# write out the data types in full, for plotting
data[,phenotype := factor(phenotype, levels=data.types, labels=data.types.long)]
data[,mediator := factor(mediator, levels=data.types, labels=data.types.long)]

# plot a histogram of the calls for each mediator/phenotype pair
pdf(file.path("plots", "cit_qtl.pdf"))
ggplot(data, aes(x=model)) +
    geom_histogram() +
    facet_grid(mediator~phenotype, labeller = label_both) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1))
dev.off()
