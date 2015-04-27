#!/usr/bin/env Rscript

sink("/dev/null")
library(data.table)
library(knitr)

data.types <- c("e", "ace", "me")
pc.rm <- c(e=10, ace=10, me=10)

files <- sprintf(file.path("results", "%sQTL", "PC%d.best.tsv"), data.types, pc.rm)
data <- lapply(files, fread)

tbl <- as.data.frame(lapply(data, "[", j=sum(q.value < 0.05)))
colnames(tbl) <- c("genes", "peaks", "CpGs")
sink()
kable(tbl, "markdown")
