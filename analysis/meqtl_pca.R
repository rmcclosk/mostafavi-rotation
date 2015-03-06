#!/usr/bin/env Rscript

# check if first PC of all CpGs for the same meQTL correlates with the SNP

library(reshape2)
library(data.table)
library(ggplot2)

# read patient IDs
cat("Reading patient IDs\n")
keep.cols <- c("methylation.id", "genotype.id", "projid", "use.for.qtl")
id.map <- fread("../data/patients.tsv", select=keep.cols)
id.map <- id.map[which(use.for.qtl)]
setkey(id.map, methylation.id)

# read meQTLs
cat("Reading meQTLs\n")
meqtl <- fread("../primary/meQTL/best.tsv", 
               select=c("snp", "feature", "adj.p.value", "q.value"))
setkey(meqtl, feature, adj.p.value)
meqtl <- meqtl[,.SD[1], by=feature]
meqtl <- meqtl[q.value < 0.05,]
meqtl[,n.cpgs := length(feature), by=snp]
meqtl <- meqtl[n.cpgs > 1,]
setkey(meqtl, feature, snp)

# get columns of methylation data to read
cat("Preselecting columns for methylation data\n")
mfile <- "../data/ill450kMeth_all_740_imputed.txt"
mpatients <- tail(strsplit(readLines(mfile, n=1), "\t")[[1]], -1)
keep.cols <- na.omit(id.map[,match(methylation.id, mpatients)])
mprojid <- id.map[mpatients[keep.cols],projid]

# get rows of methylation data to read
cat("Preselecting rows for methylation data\n")
mfeatures <- fread(mfile, skip=1, select=1)[,V1]
keep.rows <- sort(match(meqtl[,feature], mfeatures))

# read methylation data
cat("Reading methylation data\n")
mdata <- fread(mfile, select=c(1, keep.cols+1))
setnames(mdata, "TargetID", "feature")
mdata <- mdata[keep.rows,]
setkey(mdata, feature)
setnames(mdata, mpatients[keep.cols], as.character(mprojid))
stopifnot(mdata[,feature] == unique(meqtl[,feature]))

# transpose methylation data
cat("Transposing methylation data\n")
mdata <- melt(mdata, id.vars=c("feature"), variable.name="projid")
mdata <- dcast.data.table(mdata, projid~feature)
setkey(mdata, projid)

# get genotype data
cat("Reading genotype manifest\n")
manifest <- fread("../data/genotype_manifest.tsv")
manifest <- manifest[match(meqtl[,snp], snp)]
setkey(manifest, snp)
manifest <- unique(manifest)
manifest[,file := paste0("../data/", file)]

cat("Preselecting rows for genotype data\n")
setkey(id.map, genotype.id)
gfile <- "../data/transposed_1kG/chr1/chr1.560001.560059.snplist.test.snps.dosage.1kg.trans.txt"
gpatients <- fread(gfile, select=1, skip=1)[,V1]
keep.rows <- sort(match(id.map[,genotype.id], gpatients))
gprojid <- id.map[gpatients[keep.rows], projid]
sed.cmd <- paste0("sed '", paste0(c(1, 1+keep.rows), collapse="p;"), "q;d'")

cat("Reading genotype data\n")
pb <- txtProgressBar(0, manifest[,length(unique(file))], style=3)
gdata <- by(manifest, manifest[,file], function (x) {
    d <- fread(paste(sed.cmd, x[1,file]), select=c(1, 1+x[,column]), skip=1)
    setnames(d, colnames(d), c("projid", x[,snp]))
    stopifnot(d[,projid] == gpatients[keep.rows])
    d[,projid := gprojid]
    setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
    setkey(d, projid)
})
close(pb)
gdata <- Reduce(merge, gdata)
setkey(gdata, projid)

cor.spearman <- function (x, y)
    cor.test(x, y, method="spearman")$p.value

cor.pca <- function (geno, methyl) 
    log10(cor.spearman(geno, prcomp(methyl)$x[,1]))

mean.cor <- function (geno, methyl)
    mean(sapply(methyl, function (m) log10(cor.spearman(geno, m))))

meqtl[,cor.pca := cor.pca(gdata[[as.character(snp)]], mdata[,feature,with=FALSE]), snp]
meqtl[,mean.log.p := mean.cor(gdata[[as.character(snp)]], mdata[,feature,with=FALSE]), snp]

meqtl[,n.cpgs := cut(n.cpgs, breaks=5)]
png("meqtl_pca.png")
ggplot(meqtl, aes(x=-mean.log.p, y=-cor.pca, col=n.cpgs, shape=n.cpgs)) +
    geom_point(size=3) +
    stat_function(fun=identity, col="black", linetype="dashed") +
    scale_y_log10() +
    scale_x_log10() +
    xlab("mean -log P-value of meQTL correlations") +
    ylab("-log P-value of correlation with PC1") +
    theme_bw()
dev.off()
