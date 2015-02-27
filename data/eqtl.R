#!/usr/bin/env Rscript

library(qvalue)
library(data.table)
library(MatrixEQTL)

source(file="liftover.R")

scale.rank <- function (x, ...) scale(rank(x, ...))

make.sliced.data <- function (data) {
    data <- t(apply(data, 1, scale.rank, ties.method="average"))
    SlicedData$new()$CreateFromMatrix(data)
}

cis.outfile = tempfile()
trans.outfile = tempfile()

# read expression data and get common patient IDs
gene <- fread("residual_gene_expression_expressed_genes_2FPKM100ind.txt")
gene[,V1 := as.integer(gsub(":.*", "", V1))]

snp.id <- readLines("transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt", n=1)
snp.id <- strsplit(snp.id, " ")[[1]]
classes <- c("character", rep("NULL", length(snp.id)))
snps <- fread("transposed_1kG/chr22/chr22.90001.98086.snplist.test.snps.dosage.1kg.trans.txt", colClasses=classes)
snps[,V1 := as.integer(gsub("[A-Z]", "", V1))]

setkey(gene, V1)
setkey(snps, V1)
patient.id <- merge(snps[,"V1", with=FALSE], gene[,"V1", with=FALSE])
gene <- unique(gene)[patient.id,][,V1 := NULL]

split <- strsplit(colnames(gene), ":")
gene.name <- sapply(split, "[[", 1)
probe <- sapply(split, "[[", 2)
id <- as.integer(sub("ENSG", "", probe))
gene <- t(as.matrix(gene))
dimnames(gene) <- list(probe, patient.id[,V1])
gene <- make.sliced.data(gene)

# get gene locations
gene.id <- setkey(data.table(id=id, PROBE=probe, GENE=gene.name), id)

classes <- c("integer", "NULL", rep("integer", 3), "logical")
genepos <- fread("ensemblGenes.tsv", colClasses=classes)
setnames(genepos, colnames(genepos), c("id", "GENE_CHR", "start", "end", "forward"))
genepos[,TSS_POS := ifelse(forward, start, end)]
genepos[,c("start", "end", "forward") := NULL]

genepos <- merge(setkey(genepos, id), gene.id)[,id := NULL]
setkey(genepos, PROBE)

get.snpspos <- function (snp.file, rsid) {
    # read SNP positions
    snpspos <- readLines(snp.file, n=1)
    snpspos <- data.table(SNP=strsplit(snpspos, " ")[[1]])
    snpspos[,id := 1:nrow(snpspos)]
    
    # lift over SNPs in chrN:POS format
    chrpos <- snpspos[grepl("chr", SNP)]
    if (nrow(chrpos) > 0) {
        chrpos[,c("SNP_CHR", "SNP_POS") := as.list(as.integer(strsplit(sub("chr", "", SNP), ":")[[1]])), by=SNP]
        chrpos[,c("SNP_CHR", "SNP_POS") := liftover(SNP_CHR, SNP_POS)]
        chrpos[,SNP := NULL]
    }
    
    # get positions for SNPs with RSIDs
    rs <- snpspos[grepl("rs", SNP),]
    rs[,c("SNP_CHR", "SNP_POS") := rsid[rs, c("SNP_CHR", "SNP_POS"), with=FALSE]]
    rs[,SNP := NULL]
    
    # combine both sets of positions
    if (nrow(chrpos) > 0)
        chrpos <- setkey(rbind(rs, chrpos), id)
    else
        chrpos <- setkey(rs, id)
    setkey(snpspos, id)
    setcolorder(chrpos[snpspos][,id := NULL], c("SNP", "SNP_CHR", "SNP_POS"))
}

sapply(14:1, function (chr) {

    # read RSIDs
    rsid <- fread(sprintf("SNPChrPosOnRef/chr%s.bcp", chr))
    setnames(rsid, c("V1", "V2", "V3"), c("SNP", "SNP_CHR", "SNP_POS"))
    rsid[,SNP := paste0("rs", SNP)]
    setkey(rsid, SNP)
    
    snp.files <- Sys.glob(sprintf("transposed_1kG/chr%d/chr%d.*.trans.txt", chr, chr))
    
    eqtls <- Reduce(function (x, snp.file) {
        snpspos <- get.snpspos(snp.file, rsid)
        classes <- c("character", snpspos[,ifelse(is.na(SNP_CHR) | is.na(SNP_POS), "NULL", "numeric")])
        snpspos <- snpspos[!is.na(SNP_CHR) & !is.na(SNP_POS),]
        
        # read SNP values
        print(snp.file)
        snps <- fread(snp.file, colClasses=classes)
        snps[,V1 := as.integer(gsub("[A-Z]", "", V1))]
        setkey(snps, V1)
        snps <- unique(snps)[patient.id,][,V1 := NULL]
        
        snps <- t(as.matrix(snps))
        dimnames(snps) <- list(snpspos[,SNP], patient.id[,V1])
        snps <- make.sliced.data(snps)
        setDF(snpspos)
        
        # run Matrix eqTL
        Matrix_eQTL_main(
            snps = snps, 
            gene = gene, 
            cvrt = SlicedData$new(),
            output_file_name = trans.outfile,
            pvOutputThreshold = 0,
            useModel = modelLINEAR,
            errorCovariance = numeric(), 
            verbose = FALSE, 
            output_file_name.cis = cis.outfile,
            pvOutputThreshold.cis = 1,
            snpspos = snpspos, 
            genepos = setDF(genepos[,c("PROBE", "GENE_CHR", "TSS_POS", "TSS_POS"),with=FALSE]),
            cisDist = 1000000,
            pvalue.hist = FALSE,
            min.pv.by.genesnp = FALSE,
            noFDRsaveMemory = TRUE)
        
        res <- fread(cis.outfile)
        if (nrow(res) == 0)
            return (x)

        # because we scaled the data to have SD=1, beta = rho
        # (ie. regression slope = correlation coefficient)
        setnames(res, c("gene", "beta", "p-value"), c("PROBE", "RHO", "PVALUE"))
        res[,"t-stat" := NULL, with=FALSE]
        setkey(res, SNP)
        setDT(snpspos)
        rbind(x, merge(res, snpspos))
    }, snp.files, init=NULL) # Reduce
    
    setkey(eqtls, PROBE)
    eqtls <- merge(eqtls, genepos)
    eqtls[,DISTANCE := abs(TSS_POS-SNP_POS)]
    eqtls[,"-LOG10PVALUE" := -log10(PVALUE)]
    write.table(eqtls, sprintf("eQTL/chr%d.tsv", chr), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
}) # Reduce

unlink(cis.outfile)
unlink(trans.outfile)
