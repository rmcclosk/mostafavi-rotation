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

checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("cit_qtl_", checksum, ".Rdata"))

data.types <- c("e", "ace", "me")
tests <- setDT(expand.grid(mediator=data.types, phenotype=data.types, stringsAsFactors=FALSE))
tests <- tests[mediator != phenotype]

do.test <- function (data, mediator, phenotype)
    do.call(CausalityTestJM, unname(as.list(data[,c("g", mediator, phenotype), with=FALSE])))[3]
do.test <- Vectorize(do.test, c("mediator", "phenotype"))

if (!file.exists(cache.file)) {
    data <- fread(file.path("results", "multi_qtl_data.tsv"))
    data <- data[, cbind(tests, with(tests, do.test(.SD, mediator, phenotype))), snp]
    setnames(data, "V2", "model")
    save(data, file=cache.file)
} else {
    load(cache.file)
}

model.types <- c("no call", "causal", "reactive", "independent/other")
data[,model := model.types[model+1]]
data[,model := factor(model, levels=model.types)]

p <- ggplot(data, aes(x=model)) +
    geom_histogram() +
    facet_grid(mediator~phenotype, labeller = label_both) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

png(file.path("plots", "cit_qtl.png"))
print(p)
dev.off()

pdf(file.path("plots", "cit_qtl.pdf"))
print(p)
dev.off()
