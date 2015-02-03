#!/usr/bin/env Rscript

# Bayesian network on phenotypes with the deal package.

library(RPostgreSQL)
library(qvalue)

set.seed(0)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

query <- paste("SELECT * FROM eqtl ORDER BY gene_id, position")
data <- dbGetQuery(con, query)
dbDisconnect(con)

#cat(length(unique(data$gene_id)), " genes tested\n")
#cat(sum(tapply(data$position, data$chrom, function (x) length(unique(x)))), " SNPs tested\n")
#cat(nrow(data), "total tests\n")
#cat("Summary of SNPs per gene:\n")
#summary(tapply(data$p_value, data$gene_id, length))

data$qvalue <- qvalue(data$p_value)$qvalue
signif <- subset(data, qvalue < 0.05)

cat(nrow(signif), "eQTL associations\n")
cat(length(unique(signif$gene_id)), " genes with eQTLs\n")
cat(sum(tapply(signif$position, signif$chrom, function (x) length(unique(x)))), " eQTL loci\n")
cat("Summary of eQTLs per gene:\n")
summary(tapply(signif$p_value, signif$gene_id, length))

sum(signif$rho > 0)
summary(subset(signif, rho > 0)$rho)
sum(signif$rho < 0)
summary(subset(signif, rho < 0)$rho)
