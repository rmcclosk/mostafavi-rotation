#!/usr/bin/env Rscript

# check if first PC of all CpGs for the same meQTL correlates with the SNP

library(RPostgreSQL)
library(data.table)
library(ggplot2)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

get.dt <- function (query) 
    setDT(dbGetQuery(con, query))
get.dt.pid <- function(query) 
    setkey(get.dt(query), patient_id)

mpatients <- get.dt.pid("SELECT distinct patient_id FROM methylation_chr22")
gpatients <- get.dt.pid("SELECT distinct patient_id FROM genotype_chr22")
patients <- merge(mpatients, gpatients)

meqtl.query <-paste("SELECT DISTINCT ON (cpg_position) * FROM meqtl_chr%d",
                    "WHERE q_value < 0.05 ORDER BY cpg_position, adj_p_value",
                    "LIMIT 100")
mquery <- paste("SELECT patient_id, value AS value%d",
                "FROM methylation_chr%d WHERE position = %d")
gquery <- paste("SELECT patient_id, value AS genotype",
                "FROM genotype_chr%d WHERE position = %d")


meqtls <- do.call(rbind, lapply(1:22, function (chr) {

    get.methyl <- function (pos) 
        get.dt.pid(sprintf(mquery, pos, chr, pos))
    
    get.all.methyl <- function (positions)
        Reduce(merge, lapply(positions, get.methyl))[patients][,patient_id := NULL]
    
    get.genotype <- function (pos)
        get.dt.pid(sprintf(gquery, chr, pos))[patients,genotype]
    
    cor.pca <- function (geno, methyl) 
        log10(cor.test(geno, prcomp(methyl)$x[,1], method="spearman")$p.value)
    
    cat("Chromosome", chr, "\n")
    meqtls <- get.dt(sprintf(meqtl.query, chr))
    
    meqtls[,cor.pca := cor.pca(get.genotype(snp_position), get.all.methyl(cpg_position)), snp_position]
    meqtls[,mean.log.p := mean(log10(p_value)), snp_position]
    meqtls[,n.cpgs := length(unique(cpg_position)), snp_position]
}))

meqtls <- subset(meqtls, n.cpgs > 1)
meqtls[, n.cpgs := cut(n.cpgs, breaks=5)]
head(setkey(meqtls, snp_position))
png("meqtl_pca.png")
ggplot(meqtls, aes(x=-mean.log.p, y=-cor.pca, col=n.cpgs, shape=n.cpgs)) +
    geom_point(size=3) +
    stat_function(fun=identity, col="black", linetype="dashed") +
    scale_y_log10() +
    scale_x_log10() +
    xlab("mean -log P-value of meQTL correlations") +
    ylab("-log P-value of correlation with PC1") +
    theme_bw()
dev.off()

dbDisconnect(con)
