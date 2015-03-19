#!/usr/bin/env Rscript

# When us and ROSMAP identified the same genes, check the correlation of the
# SNPs.

library(data.table)
library(qvalue)
library(ggplot2)

#keeps <- c("PROBE", "SNP", "PERMUTATIONP")
#theirs <- fread("../data/ROSMAP_brain_rnaseq_best_eQTL.txt", select=keeps)
#setnames(theirs, "PROBE", "feature")
#setnames(theirs, "SNP", "snp")
#setnames(theirs, "PERMUTATIONP", "adj.p.value")
#
#theirs[,feature := as.integer(gsub("ENSG|[.].*", "", feature))]
#theirs[,q.value := qvalue(adj.p.value)$qvalue]
#theirs[,adj.p.value := NULL]
#theirs <- theirs[q.value < 0.05,]
#setkey(theirs, feature)
#
#keeps <- c("feature", "snp", "q.value.PC10")
#classes <- list(character="snp")
#ours <- fread("../primary/eQTL/best.tsv", select=keeps, colClasses=classes)
#setnames(ours, "q.value.PC10", "q.value")
#
#ours <- ours[!duplicated(feature) & q.value < 0.05,]
#ours[,snp := paste0("rs", snp)]
#setkey(ours, feature)
#
#qtl.data <- merge(ours, theirs, suffixes=c(".ours", ".theirs"))
#
#snps.needed <- qtl.data[,unique(c(snp.ours, snp.theirs))]
#manifest <- fread("../data/genotype_manifest.tsv")
##setnames(manifest, paste0("V", 1:3), c("file", "snp", "column"))
#manifest[,file := file.path("../data", file)]
#setkey(manifest, snp)
#manifest <- manifest[snp %in% snps.needed,]
#setkey(manifest, file, column)
#
#qtl.data <- qtl.data[snp.ours %in% manifest[,snp] & snp.theirs %in% manifest[,snp],]
#
#cat("Reading genotype data\n")
#pb <- txtProgressBar(min=0, max=manifest[,length(unique(file))], style=3)
#gdata <- Reduce(cbind, by(manifest, manifest[,file], function (x) {
#    data <- fread(x[1, file], select=x[,1+column])
#    setTxtProgressBar(pb, getTxtProgressBar(pb)+1)
#    setnames(data, paste0("V", x[,1+column]),  x[,snp])
#}))
#close(pb)
#
#get.cor.p <- function (snp.ours, snp.theirs) {
#    if (snp.ours == snp.theirs) {
#        0
#    } else {
#        cor.test(rank(gdata[[snp.ours]]), rank(gdata[[snp.theirs]]))$p.value
#    }
#}
#
#qtl.data[,cor.p := get.cor.p(snp.ours, snp.theirs), feature]
#write.table(qtl.data, "snps.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
#quit()

qtl.data <- fread("snps.tsv")
qtl.data

p <- ggplot(qtl.data, aes(x=cor.p)) + geom_density() + theme_bw() + labs(x="P-value of correlation")

pdf("snps.pdf")
print(p)
dev.off()
png("snps.png")
print(p)
dev.off()
