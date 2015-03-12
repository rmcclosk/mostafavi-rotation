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

# merge all the phenotype files
p <- read.pheno("pheno_cov_n2963_092014_forPLINK.csv")
drops <- setdiff(colnames(p), c("projid"))
p <- merge(p, read.pheno("phenotype_740qc_finalFromLori.txt", drops), all=TRUE)
drops <- setdiff(colnames(p), c("projid"))
p <- merge(p, read.pheno("techvars_plus_phenotypes26SEP2014.txt", drops), all=TRUE)
setkey(p, projid)

# get which patients have which data types
apatients <- gsub('"', '', readLines("chipSeqResiduals.csv", n=1))
apatients <- as.integer(strsplit(apatients, "\t")[[1]])
p[,acetylation.id := apatients[match(projid, apatients)]]

efile <- "residual_gene_expression_expressed_genes_2FPKM100ind.txt"
epatients <- fread(efile, skip=1, select=1)[,V1]
eprojid <- as.integer(sub(":.*", "", epatients))
p[,expression.id := epatients[match(projid, eprojid)]]

mpatients <- readLines("ill450kMeth_all_740_imputed.txt", n=1)
mpatients <- tail(strsplit(mpatients, "\t")[[1]], -1)
p[,methylation.id := mpatients[match(Sample_ID, mpatients)]]

gfile <- Sys.glob("transposed_1kG/chr1/chr1.560001.560059.*.trans.txt")[1]
gpatients <- fread(gfile, skip=1, select=1)[,V1]
gprojid <- as.integer(gsub("[A-Z]", "", gpatients))
p[,genotype.id := gpatients[match(projid, gprojid)]]

# which patients we are using for the experiments
id.vars <- c("methylation.id", "genotype.id", "expression.id", "acetylation.id")
cov.vars <- c("pmi", "msex", "age_death", "EV1", "EV2", "EV3")
drop.rows <- p[,unique(which(is.na(.SD), arr.ind=TRUE)[,"row"]), .SDcols=c(id.vars, cov.vars)]
p[,use.for.qtl := TRUE]
p[drop.rows, use.for.qtl := FALSE]

write.table(p, "patients.tsv", row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")
