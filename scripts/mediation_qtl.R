#!/usr/bin/env Rscript

# Do tests for each of the possible mediating relationships among data types.

library(data.table)
library(mediation)
library(pheatmap)
library(knitr)
library(parallel)
library(tools)

source(file=file.path("utils", "causal.R"))

ncpus <- commandArgs(trailingOnly=TRUE)[2]

vars <- c("e", "ace", "me")
tests <- subset(expand.grid(vars, vars), Var1 != Var2)
tests <- rbind(tests, apply(tests, 2, paste0, ".orig"))

all.tests <- function (data, pb) {
    cbind(tests, p.value=apply(tests, 1, function (x) {
        res <- mediates("g", x[1], x[2], data)$d.avg.p
        setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
        res
    }))
}

checksum <- substr(md5sum(file.path("results", "multi_qtl_data.tsv")), 1, 6)
cache.file <- file.path("cache", paste0("mediation_qtl_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    d <- fread(file.path("results", "multi_qtl_data.tsv"))
    setkey(d, snp)

    pb <- txtProgressBar(min=0, max=nrow(unique(d))*nrow(tests), style=3)
    med <- rbindlist(mclapply(unique(d[,snp]), function (x) {
        all.tests(d[snp == x,], pb)
    }, mc.cores=ncpus))
    close(pb)
    save(med, file=cache.file)
} else {
    load(cache.file)
}

setnames(med, c("Var1", "Var2"), c("mediator", "phenotype"))
med[, data.type := ifelse(grepl("orig", mediator), "original", "reduced")]
med[, mediator := gsub(".orig", "", mediator)]
med[, phenotype := gsub(".orig", "", phenotype)]

tbl <- med[p.value < 0.05 & data.type == "reduced", table(mediator, phenotype)]
tbl <- tbl/med[,sum(data.type == "reduced")/6]
disp.tbl <- round(tbl*100) # percentage
diag(disp.tbl) <- ""
cat(kable(disp.tbl, "markdown"), file=file.path("tables", "mediation_qtl.md"), sep="\n")

diag(tbl) <- NA
png(file.path("plots", "mediation_qtl.png"))
pheatmap(tbl, cluster_rows=FALSE, cluster_columns=FALSE, fontsize=20)
dev.off()
