#!/usr/bin/env Rscript

# check if first PC of all CpGs for the same meQTL correlates with the SNP

library(reshape2)
library(data.table)
library(ggplot2)
library(tools)
source(file=file.path("utils", "load_data.R"))
source(file=file.path("utils", "misc.R"))

pc.use <- 10

cor.spearman <- function (x, y)
    cor.test(x, y, method="spearman")$p.value

cor.pca <- function (geno, methyl) 
    -log10(cor.spearman(geno, prcomp(methyl)$x[,1]))

meqtl.file <- file.path("results", "meQTL", paste0("PC", pc.use, ".best.tsv"))
checksum <- substr(md5sum(meqtl.file), 1, 6)
cache.file <- file.path("cache", paste0("meqtl_pca_", checksum, ".Rdata"))

if (!file.exists(cache.file)) {
    # read patient IDs
    patients <- load.patients()
    
    # read meQTLs
    meqtl <- fread(meqtl.file)[q.value < 0.05,]
    meqtl[,n.cpgs := length(feature), by=snp]
    meqtl <- meqtl[n.cpgs > 1,]
    setkey(meqtl, feature, snp)

    # get genotype data
    manifest <- setkey(load.manifest(), snp)
    manifest <- merge(manifest, meqtl[,"snp", with=FALSE])
    manifest <- unique(setkey(manifest, snp))
    setkey(manifest, file, column)
    gdata <- load.gdata(manifest, patients)
    
    # read methylation data
    mdata <- rm.pcs(load.mdata(patients), pc.use)
    
    # keep just the CpGs with a QTL
    mdata <- mdata[,colnames(mdata) %in% meqtl[,feature]]

    stopifnot(rownames(mdata) == rownames(gdata))

    meqtl[,PC1 := cor.pca(gdata[,as.character(snp)], mdata[,feature]), snp]
    stats <- meqtl[,as.list(summary(-log10(adj.p.value))), snp]

    setkey(meqtl, snp)
    setkey(stats, snp)
    stats <- merge(unique(meqtl), unique(stats))

    stats[,c("feature", "rho", "t.stat", "p.value", "adj.p.value", "n.cpgs", "q.value") := NULL]
    save(stats, file=cache.file)

} else {
    load(cache.file)
}

#stats <- melt(stats, id.vars="snp", variable.name="statistic", value.name="value")
#levels(stats$statistic) <- c("PC1", "Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max.")

stats <- melt(stats, id.vars=c("snp", "PC1"), variable.name="statistic", value.name="value")
stats[PC1 == Inf, PC1 := 200] # TODO: better value

p <- ggplot(stats, aes(x=value, y=PC1)) +
    stat_binhex() +
    labs(x="-log10 P-value of correlation with CpG", y="-log10 P-value of correlation with PC1")  +
    facet_wrap(~statistic) +
    theme_bw() +
    geom_abline(intercept=0, slope=1, color="red")

png(file.path("plots", "meqtl_pca.png"))
print(p)
dev.off()

pdf(file.path("plots", "meqtl_pca.pdf"))
print(p)
dev.off()
