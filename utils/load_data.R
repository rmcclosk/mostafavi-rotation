#!/usr/bin/env Rscript

# These functions provide easy (sort of) access to the raw data.

library(data.table)

# load the patient data
load.patients <- function () {
    pfile <- file.path("data", "patients.tsv")
    fread(pfile)[which(use.for.qtl)]
}

# read all the methylation data at once
# id.map is a data.table which has at least the columns "methylation.id" and
# "projid"
# data will be returned for only the patients in id.map
# id.map can be made by using the function load.patients
load.mdata <- function (id.map=load.patients(), cpgs=load.cpgs(), ...) {
    mfile <- file.path("data", "ill450kMeth_all_740_imputed.txt")

    # the methylation data has patients as columns
    # find the column indices for patients we want
    mpatient <- tail(strsplit(readLines(mfile, n=1), "\t")[[1]], -1)
    idx <- which(mpatient %in% id.map[,methylation.id])
    
    # read the data; first column is the CpG ID
    mdata <- fread(mfile, select=c(1, 1+idx), skip=1, ...)
    mfeature <- mdata[,V1]

    # keep only the features we need
    keeps <- na.omit(cpgs[,match(feature, mfeature)])
    mdata <- mdata[,V1 := NULL][keeps,]

    # set the column names to the patient IDs
    setkey(id.map, methylation.id)
    mprojid <- as.character(id.map[mpatient[idx], projid])
    setnames(mdata, paste0("V", 1+idx), mprojid)

    # make a matrix with patients as rows and CpGs as columns
    mdata <- t(mdata)
    colnames(mdata) <- mfeature[keeps]
    mdata
}

# read all the acetylation.data
# see load.mdata for the meaning of the parameter
# peaks is a data.table with at least the column "feature" which tells us which
# peaks to load
load.adata <- function (id.map=load.patients(), peaks=load.peaks(), ...) {
    # acetylation data has peaks for rows and patients for columns
    # find the column indices of patients we want
    afile <- file.path("data", "chipSeqResiduals.csv")
    apatients <- as.integer(strsplit(gsub('"', "", readLines(afile, n=1)), "\t")[[1]])
    idx <- which(apatients %in% id.map[,projid])
    
    # read the data; the first column in the peak ID
    adata <- na.omit(fread(afile, skip=1, select=c(1, 1+idx), ...))
    afeature <- sub("peak", "", adata[,V1])

    # take only the peaks we need
    keeps <- na.omit(peaks[,match(feature, afeature)])
    
    # make a matrix with patients as rows and peaks as columns
    adata <- t(adata[,V1 := NULL][keeps,])
    dimnames(adata) <- list(apatients[idx], afeature[keeps])
    adata
}

# read gene expression data
# see load.mdata for the meaning of the id.map parameter
# genes is a data.table with at least the column "feature" indicating which
# genes to load
load.edata <- function (id.map=load.patients(), genes=load.genes(), ...) {
    # the gene expression data has patients as rows and genes as columns
    efile <- file.path("data", "residual_gene_expression_expressed_genes_2FPKM100ind.txt")

    # get the gene IDs from the column names
    efeature <- tail(strsplit(readLines(efile, n=1), "\t")[[1]], -1)
    efeature <- as.integer(gsub(".*:ENSG|[.].*", "", efeature))
    keeps <- sort(na.omit(genes[,match(feature, efeature)]))
    efeature <- efeature[keeps]
    
    # read the data
    edata <- fread(efile, skip=1, select=c(1, 1+keeps), ...)
    setnames(edata, "V1", "expression.id")
    
    # since we read in all the patients, delete the ones we're not using
    setkey(edata, expression.id)
    setkey(id.map, expression.id)
    edata <- merge(edata, id.map[,"expression.id", with=FALSE])

    # now change the IDs in the expression file into projids
    eprojid <- id.map[edata[,expression.id], projid]
    edata[,expression.id := NULL]
    
    # make a matrix with patients as rows and genes as columns
    edata <- as.matrix(edata)
    dimnames(edata) <- list(eprojid, efeature)
    edata
}

load.manifest <- function (...) {
    fread(file.path("data", "genotype_manifest.tsv"), ...)
}

# read genotype data
# manifest is a data.table with at least the columns file, snp, and column
# it can be produced by load.manifest
# see load.mdata for the description of the id.map parameter
load.gdata <- function (manifest, id.map=load.patients()) {

    # get the IDs from the first file
    gid <- fread(manifest[1, file], select=1, skip=1)[,V1]
    keep.rows <- na.omit(match(id.map[,genotype.id], gid))
    gid <- gid[keep.rows]
    projid <- id.map[match(gid, id.map[,genotype.id]), as.character(projid)]

    # go through each file with SNPs we need
    pb <- txtProgressBar(min=0, max=nrow(manifest), style=3, file=stderr())
    data <- do.call(cbind, by(manifest, manifest[,file], function (x) {

        # the genotype data has patients as rows and SNPs as columns
        # read the genotype data from the file, selecting only the needed
        tmp <- copy(x)
        setkey(tmp, column)
        snp.cols <- tmp[,1+column]
        data <- fread(tmp[1, file], select=snp.cols, skip=1)

        # we read the data for all patients, so keep only those we want
        data <- data[keep.rows,]

        setTxtProgressBar(pb, getTxtProgressBar(pb) + nrow(tmp))

        # rename the columns to the SNP IDs
        as.matrix(setnames(data, paste0("V", snp.cols), tmp[,snp]))

    }, simplify=FALSE))
    rownames(data) <- projid
    close(pb)
    data
}

# read the list of SNP positions
load.snps <- function () {
    snpspos <- fread(file.path("data", "snp.txt"), drop=3)
    setnames(snpspos, colnames(snpspos), c("chr", "pos", "snp"))
    snpspos[,chr := as.integer(sub("chr", "", chr))]
    setcolorder(snpspos, c("snp", "chr", "pos"))
}

# read the list of CpG positions
load.cpgs <- function () {
    mepos <- fread(file.path("data", "cpg.txt"), drop=3)
    setnames(mepos, colnames(mepos), c("chr", "pos", "feature"))
    mepos[,chr := sub("chr", "", chr)]
    setcolorder(mepos, c("feature", "chr", "pos"))
}

# read the list of peak positions
load.peaks <- function () {
    acepos <- fread(file.path("data", "peak.txt"))
    setnames(acepos, colnames(acepos), c("chr", "start", "end", "feature"))
    acepos[,feature := as.integer(sub("peak", "", feature))]
    acepos[,chr := as.integer(sub("chr", "", chr))]
    acepos[,pos := as.integer((start+end)/2)]
    acepos[,c("start", "end") := NULL]
    setcolorder(acepos, c("feature", "chr", "pos"))
}

# read the list of genes
load.genes <- function () {
    genepos <- fread(file.path("data", "ensemblGenes.tsv"), drop=2)
    setnames(genepos, colnames(genepos), c("feature", "chr", "start", "end", "fwd"))
    genepos[,pos := ifelse(fwd, start, end)]
    genepos[,c("start", "end", "fwd") := NULL]
    setcolorder(genepos, c("feature", "chr", "pos"))
}
