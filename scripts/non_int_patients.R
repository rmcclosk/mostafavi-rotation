#!/usr/bin/env Rscript

library(ggplot2)
source(file=file.path("utils", "load_data.R"))

cache.file <- file.path("scratch", "non_int_patients.Rdata")
if (!file.exists(cache.file)) {
    manifest <- setkey(load.manifest(), snp)
    patients <- load.patients()
    snps <- setkey(load.snps(), snp)
    manifest <- merge(manifest, snps)
    setkey(manifest, file, column)
    
    chunk.size <- 10000
    manifest[,chunk := rep(1:(nrow(.SD)/chunk.size+1), each=chunk.size)[1:nrow(.SD)]]

    non.int.count <- function (x) sum(x != as.integer(x))
    do.count <- function (gdata) {
        data.table(projid=rownames(gdata), count=apply(gdata, 1, non.int.count))
    }
    manifest <- manifest[!is.na(file), do.count(load.gdata(cbind(.SD, file=.BY[[1]]), patients)), by=chunk]
    save(manifest, file=cache.file)
} else {
    load(cache.file)
}

p <- ggplot(manifest, aes(x=count)) + geom_histogram(binwidth=1) + theme_bw()

pdf(file.path("plots", "non_int_patients.pdf"))
print(p)
dev.off()

png(file.path("plots", "non_int_patients.png"))
print(p)
dev.off()
