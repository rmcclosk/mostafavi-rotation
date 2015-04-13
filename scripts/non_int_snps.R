#!/usr/bin/env Rscript

library(ggplot2)
source(file=file.path("utils", "load_data.R"))

cache.file <- file.path("cache", "non_int_snps.Rdata")
if (!file.exists(cache.file)) {
    manifest <- setkey(load.manifest(), snp)
    snps <- setkey(load.snps(), snp)
    patients <- load.patients()
    
    manifest <- setkey(manifest[snps], file, column)
    
    chunk.size <- 10000
    manifest[,chunk := rep(1:(nrow(.SD)/chunk.size+1), each=chunk.size)[1:nrow(.SD)]]
    
    non.int.count <- function (x) sum(x != as.integer(x))
    
    manifest[!is.na(file), count := apply(load.gdata(.SD, patients), 2, non.int.count), chunk]
    save(manifest, file=cache.file)
} else {
    load(cache.file)
}

p <- ggplot(manifest, aes(x=count)) + 
     geom_histogram(binwidth=1) +
     labs(x="samples with non-integer data", y="number of SNPs") +
     theme_bw() +
     scale_y_log10()

pdf(file.path("plots", "non_int_snps.pdf"), width=7*1.5, height=7*0.75)
print(p)
dev.off()

png(file.path("plots", "non_int_snps.png"), width=480*1.5, height=480*0.75)
print(p)
dev.off()
