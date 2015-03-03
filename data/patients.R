#!/usr/bin/env Rscript

# collate all phenotype and data type information about all patients into one
# file

library(data.table)

read.pheno <- function (pheno.file, drops=NULL) {
    p <- setkey(fread(pheno.file, drop=drops), projid)
    p <- unique(p)
    
    # -9 means null
    p[which(p == -9, arr.ind=TRUE),] <- NA

    # exactly zero in a numeric column means null
    num.cols <- p[,which(lapply(.SD, class) == "numeric")]
    zeros <- p[,which(p == 0, arr.ind=TRUE)]
    zeros <- zeros[zeros[,2] %in% num.cols,]
    p[zeros,] <- NA
    p
}

p <- read.pheno("pheno_cov_n2963_092014_forPLINK.csv")
drops <- setdiff(colnames(p), c("projid"))
p <- merge(p, read.pheno("phenotype_740qc_finalFromLori.txt", drops), all=TRUE)
drops <- setdiff(colnames(p), c("projid"))
p <- merge(p, read.pheno("techvars_plus_phenotypes26SEP2014.txt", drops), all=TRUE)

write.table(p, "patients.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
