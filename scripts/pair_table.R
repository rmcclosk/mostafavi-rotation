#!/usr/bin/env Rscript

library(data.table)
library(reshape2)
library(knitr)
source(file=file.path("utils", "load_data.R"))

data.types <- c("e", "ace", "me")

count.signif <- Vectorize(function (dt1, dt2) {
    file.name <- sprintf("%s_%s.tsv", dt1, dt2)
    file.name <- file.path("results", "pairs", file.name)
    fread(file.name, select="q.value")[,sum(q.value < 0.05)]
})

data.funs <- c(e=load.edata, ace=load.adata, me=load.mdata)
patients <- load.patients()[1,]
count.all <- Vectorize(function (dt) {
    ncol(data.funs[[dt]](patients))
})

tbl <- setDT(expand.grid(data.types, data.types))
tbl[which(Var1 != Var2), count := count.signif(Var1, Var2)]
tbl[which(Var1 == Var2), count := count.all(Var1)]
tbl <- matrix(tbl$count, nrow=3)
dimnames(tbl) <- list(data.types, data.types)

kable(tbl, "markdown")
