#!/usr/bin/env Rscript

library(ggplot2)
source(file=file.path("utils", "load_data.R"))

manifest <- setkey(load.manifest(), snp)
snps <- setkey(load.snps(), snp)
patients <- load.patients()

manifest <- setkey(manifest[snps], file, column)

chunk.size <- 10000
manifest[,chunk := rep(1:(nrow(.SD)/chunk.size+1), each=chunk.size)[1:nrow(.SD)]]

non.int.count <- function (x, thresh=0) {
    count <- sum(abs(x - as.integer(x)) > thresh)
    if (count == 0)
        "0"
    else if (count < 10)
        "1-9"
    else if (count < 100)
        "10-99"
    else
        "100+"
}

manifest <- rbindlist(lapply(c(0, 0.05, 0.1), function (thresh) {
    x <- copy(manifest)
    x[!is.na(file), non.int.count := apply(load.gdata(.SD, patients), 2, non.int.count, thresh), chunk]
    x[is.na(file), non.int.count := "no data"]
    x[,non.int.count := factor(non.int.count, levels=c("0", "1-9", "10-99", "100+", "no data"))]
    x[,threshold := thresh]
}))

p <- ggplot(manifest, aes(x=non.int.count)) + 
     geom_histogram() +
     labs(x="samples with non-integer data", y="count") +
     theme_bw() +
     facet_grid(~threshold)

pdf(file.path("plots", "imputation.pdf"), width=7*1.5)
print(p)
dev.off()

png(file.path("plots", "imputation.png"), width=480*1.5)
print(p)
dev.off()
