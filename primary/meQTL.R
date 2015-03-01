#!/usr/bin/env Rscript

# eQTL analysis

library(data.table)
library(MatrixEQTL)

source(file="QTL-common.R")

gene.file <- "../data/ill450kMeth_all_740_imputed.txt"
snp.file <- "../data/transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt"
genepos.file <- "../data/cpg.txt"
snpspos.file <- "../data/snp.txt"
pheno.file <- "../data/phenotype_740qc_finalFromLori.txt"

chunk.size <- 100000
total.lines <- 420132

# read patient data
id.map <- fread(pheno.file, select=c(1, 5))
setkey(id.map, Sample_ID)

# read patient IDs for genotype data
patient <- read.genotype.patient(snp.file)

# read patient IDs for expression data
epatient <- strsplit(readLines(gene.file, n=1), "\t")[[1]]
n.epatient <- length(epatient)-1
epatient <- epatient[2:length(epatient)]
epatient <- data.table(patient.id=id.map[epatient,projid])
patient <- patient[epatient,]
stopifnot(nrow(patient) == n.epatient) # make sure all IDs match up

# read gene positions
genepos <- fread(genepos.file, drop=3)
setnames(genepos, colnames(genepos), c("feature.chr", "feature.pos", "feature"))
genepos[,feature.chr := as.integer(sub("chr", "", feature.chr))]
genepos[,feature.pos.2 := feature.pos]
setcolorder(genepos, c("feature", "feature.chr", "feature.pos", "feature.pos.2"))

# read SNP positions
snpspos <- read.snpspos(snpspos.file)

# read expression data
gene <- fread(gene.file)
setnames(gene, "TargetID", "feature")
setkey(gene, feature)

cis.outfile <- tempfile()

sapply(1:1, function (chr) {

    # subset expression data
    cur.genepos <- genepos[feature.chr == chr,]
    cur.gene <- gene[cur.genepos[,feature]]
    cpgs <- cur.gene[,feature]
    cur.gene[,feature := NULL]
    cur.gene <- t(apply(cur.gene, 1, scale.rank))
    dimnames(cur.gene) <- list(cpgs, patient[,patient.id])
    cur.gene <- SlicedData$new()$CreateFromMatrix(cur.gene)

     # the genotype data is spread over multiple files
     snp.files <- Sys.glob(sprintf("../data/transposed_1kG/chr%d/chr%d.*.trans.txt", chr, chr))
     
     setDF(cur.genepos)
     eqtls <- Reduce(function (x, snp.file) {
         print(snp.file)
         rbind(x, do.matrix.eqtl(snp.file, cur.gene, cur.genepos, snpspos, patient))
     }, snp.files, init=NULL) # Reduce
     setDT(cur.genepos)
     
     # because we scaled the data to have SD=1, beta = rho
     # (ie. regression slope = correlation coefficient)
     setnames(eqtls, "beta", "rho")
 
     # to make it easier later, record the gene name, TSS position, and SNP position in the output
     setkey(eqtls, feature)
     setkey(cur.genepos, feature)
     eqtls <- merge(eqtls, cur.genepos)
     setkey(eqtls, snp)
     eqtls <- merge(eqtls, snpspos)
     eqtls[,feature.pos.2 := NULL]
     write.table(eqtls, sprintf("meQTL/chr%d.tsv", chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

})

unlink(cis.outfile)
