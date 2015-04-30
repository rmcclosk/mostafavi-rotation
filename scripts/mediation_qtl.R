#!/usr/bin/env Rscript

# Do tests for each of the possible mediating relationships among features
# associated to a multi-QTL.

library(data.table)
library(mediation)
library(pheatmap)
library(knitr)
library(parallel)
library(tools)

source(file=file.path("utils", "causal.R"))

# number of CPUs to use is the command line argument
# default to 1
ncpus <- tryCatch(as.integer(commandArgs(trailingOnly=TRUE)[2]), 
                  error = function (x) 1)

vars <- c("e", "ace", "me")
vars.long <- c("expression", "acetylation", "methylation")

# list of mediation tests to do
tests <- subset(expand.grid(vars, vars), Var1 != Var2)
tests <- rbind(tests, apply(tests, 2, paste0, ".orig"))

# function to perform each mediation test for a given data set
all.tests <- function (data, pb) {
    cbind(tests, p.value=apply(tests, 1, function (x) {
        res <- mediates("g", x[1], x[2], data)$d.avg.p
        setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
        res
    }))
}

# store intermediate data in a cache file
checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("mediation_qtl_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {

    # load the multi-QTL data
    d <- setkey(fread(file.path("results", "multi_qtl_data.tsv")), snp)

    # do all the mediation tests
    # this takes a looong time
    pb <- txtProgressBar(min=0, max=nrow(unique(d))*nrow(tests), style=3)
    med <- rbindlist(mclapply(unique(d[,snp]), function (x) {
        all.tests(d[snp == x,], pb)
    }, mc.cores=ncpus))
    close(pb)
    save(med, file=cache.file)
} else {
    load(cache.file)
}

# rename the columns for plotting
setnames(med, c("Var1", "Var2"), c("mediator", "phenotype"))

# we did the mediation tests on both orignal and PC10-reduced data
# but just keep the PC10-reduced ones
med[, data.type := ifelse(grepl("orig", mediator), "original", "reduced")]
med <- med[data.type == "reduced"]

# make sure the mediator and phenotype columns have the same factor levels,
# and add nice display labels
med[,mediator := factor(mediator, levels=vars, labels=vars.long)]
med[,phenotype := factor(phenotype, levels=vars, labels=vars.long)]

# count the number of cases where a significant (p < 0.05) mediating effect was
# observed, for each mediator/phenotype pair
tbl <- med[p.value < 0.05, table(mediator, phenotype)]

# translate counts into percentages
# we did 6 tests per multi-QTL, so divide by 1/6 the number of rows
tbl <- round(tbl*100/(nrow(med)/6))

# for printing, add a "%" sign, and make the diagonals empty
disp.tbl <- apply(tbl, 2, paste, "%")
diag(disp.tbl) <- ""
cat(kable(disp.tbl, "markdown"), file=file.path("tables", "mediation_qtl.md"), sep="\n")

# make a pretty heatmap out of the table
diag(tbl) <- NA
# http://stackoverflow.com/questions/12481267/in-r-how-to-prevent-blank-page-in-pdf-when-using-gridbase-to-embed-subplot-insi
pdf(file.path("plots", "mediation_qtl.pdf"), onefile=FALSE)
pheatmap(tbl, cluster_rows=FALSE, cluster_cols=FALSE, fontsize=20,
         legend=FALSE, display_numbers=disp.tbl, breaks=0:100)
dev.off()
