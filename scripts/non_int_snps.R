#!/usr/bin/env Rscript

library(ggplot2)
source(file=file.path("utils", "load_data.R"))

data.types <- c("e", "ace", "me")
feature.types <- c(e="TSS", ace="peak", me="CpG")
qtl.files <- file.path("results", paste0(data.types, "QTL"), "PC10.tsv")

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

cis.snps <- lapply(qtl.files, fread, select="snp")
cis.snps <- lapply(cis.snps, "[", j=unique(snp))
names(cis.snps) <- data.types

manifest[,snp.type := "all"]
setkey(manifest, snp)

cis.snps <- lapply(data.types, function (d) {
    copy(manifest[cis.snps[[d]]])[, snp.type := paste0("cis-", feature.types[[d]])]
})
manifest <- rbind(manifest, rbindlist(cis.snps))

pdf(file.path("plots", "non_int_snps.pdf"), width=7*1.5, height=7*0.75)
ggplot(manifest, aes(x=count)) + 
     geom_histogram(binwidth=1) +
     labs(x="samples per SNP with non-integer data", y="number of SNPs") +
     theme_bw() +
     scale_y_log10() +
     facet_wrap(~snp.type)
dev.off()
