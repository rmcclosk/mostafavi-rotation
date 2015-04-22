#!/usr/bin/env Rscript

# When us and ROSMAP identified the same genes, check the correlation of the
# SNPs.

library(data.table)
library(qvalue)
library(ggplot2)
library(tools)

source(file=file.path("utils", "load_data.R"))

checksum <- substr(md5sum(file.path("data", "ROSMAP_brain_rnaseq_best_eQTL.txt")), 1, 6)
cache.file <- file.path("cache", paste0("validate_snps_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    keeps <- c("PROBE", "SNP", "PERMUTATIONP")
    theirs <- fread(file.path("data", "ROSMAP_brain_rnaseq_best_eQTL.txt"), select=keeps)
    setnames(theirs, "PROBE", "feature")
    setnames(theirs, "SNP", "snp")
    setnames(theirs, "PERMUTATIONP", "adj.p.value")
    
    theirs[,feature := as.integer(gsub("ENSG|[.].*", "", feature))]
    theirs[,q.value := qvalue(adj.p.value)$qvalue]
    theirs[,adj.p.value := NULL]
    theirs <- theirs[q.value < 0.05,]
    setkey(theirs, feature)
    
    keeps <- c("feature", "snp", "q.value")
    classes <- list(character="snp")
    ours <- fread(file.path("results", "eQTL", "PC10.best.tsv"), select=keeps, colClasses=classes)
    
    ours <- ours[!duplicated(feature) & q.value < 0.05,]
    setkey(ours, feature)
    
    qtl.data <- merge(ours, theirs, suffixes=c(".ours", ".theirs"))
    
    snps.needed <- qtl.data[,unique(c(snp.ours, snp.theirs))]
    manifest <- load.manifest()
    setkey(manifest, snp)
    manifest <- manifest[snp %in% snps.needed,]
    
    qtl.data <- qtl.data[snp.ours %in% manifest[,snp] & snp.theirs %in% manifest[,snp],]
    
    patients <- load.patients()
    gdata <- load.gdata(manifest, patients)
    save(gdata, qtl.data, file=cache.file)
} else {
    load(cache.file)
}

get.cor.p <- function (snp.ours, snp.theirs) {
    if (snp.ours == snp.theirs) {
        0
    } else {
        cor.test(rank(gdata[,snp.ours]), rank(gdata[,snp.theirs]))$p.value
    }
}

qtl.data[,cor.p := get.cor.p(snp.ours, snp.theirs), feature]

p <- ggplot(qtl.data, aes(x=cor.p)) + 
    geom_density() + 
    theme_bw() + 
    labs(x="P-value of correlation")

pdf(file.path("plots", "validate_snps.pdf"))
print(p)
dev.off()

png(file.path("plots", "validate_snps.png"))
print(p)
dev.off()
