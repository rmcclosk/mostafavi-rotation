#!/usr/bin/env Rscript

# These functions provide easy (sort of) access to the raw data.

library(data.table)

# load the patient data
load.patients <- function () {
    pfile <- "../data/patients.tsv"
    fread(pfile)[which(use.for.qtl)]
}

# read all the methylation data at once
# id.map is a data.table which has at least the columns "methylation.id" and
# "projid"
# data will be returned for only the patients in id.map
# id.map can be made by using the function load.patients
load.mdata <- function (id.map) {
    mfile <- "../data/ill450kMeth_all_740_imputed.txt"

    # the methylation data has patients as columns
    # find the column indices for patients we want
    mpatient <- tail(strsplit(readLines(mfile, n=1), "\t")[[1]], -1)
    idx <- which(mpatient %in% id.map[,methylation.id])
    
    # read the data; first column is the CpG ID
    mdata <- fread(mfile, select=c(1, 1+idx), skip=1)
    feature <- mdata[,V1]
    mdata[,V1 := NULL]

    # set the column names to the patient IDs
    setkey(id.map, methylation.id)
    mprojid <- as.character(id.map[mpatient[idx], projid])
    setnames(mdata, paste0("V", 1+idx), mprojid)

    # make a matrix with patients as rows and CpGs as columns
    mdata <- t(mdata)
    colnames(mdata) <- feature
    mdata
}

# read all the acetylation.data
# see load.mdata for the meaning of the parameter
load.adata <- function (id.map) {
    # acetylation data has peaks for rows and patients for columns
    # find the column indices of patients we want
    afile <- "../data/chipSeqResiduals.csv"
    apatients <- as.integer(strsplit(gsub('"', "", readLines(afile, n=1)), "\t")[[1]])
    idx <- which(apatients %in% id.map[,projid])
    
    # read the data; the first column in the peak ID
    adata <- na.omit(fread(afile, skip=1, select=c(1, 1+idx)))
    feature <- sub("peak", "", adata[,V1])
    
    # make a matrix with patients as rows and peaks as columns
    adata <- t(adata[,V1 := NULL])
    dimnames(adata) <- list(apatients[idx], feature)
    adata
}

# read gene expression data
# see load.mdata for the meaning of the parameter
load.edata <- function (id.map) {
    # the gene expression data has patients as rows and genes as columns
    efile <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"

    # get the gene IDs from the column names
    efeature <- tail(strsplit(readLines(efile, n=1), "\t")[[1]], -1)
    efeature <- as.integer(gsub(".*:ENSG|[.].*", "", efeature))
    
    # read the data
    edata <- fread(efile, skip=1)
    setnames(edata, "V1", "expression.id")
    
    # since we read in all the patients, delete the ones we're not using
    setkey(id.map, expression.id)
    setkey(edata, expression.id)
    edata <- merge(edata, id.map[,"expression.id", with=FALSE])

    # now change the IDs in the expression file into projids
    eprojid <- id.map[edata[,expression.id], projid]
    edata[,expression.id := NULL]
    
    # make a matrix with patients as rows and genes as columns
    edata <- as.matrix(edata)
    dimnames(edata) <- list(eprojid, efeature)
    edata
}

load.manifest <- function () {
    fread("../data/genotype_manifest.tsv", nrows=10)
}

# read genotype data
# manifest is a data.table with at least the columns file, snp, and column
# it can be produced by load.manifest
# see load.mdata for the description of the id.map parameter
load.gdata <- function (manifest, id.map) {

    setkey(manifest, file, column)

    # go through each file with SNPs we need
    do.call(cbind, by(manifest, manifest[,file], function (x) {

        # the genotype data has patients as rows and SNPs as columns
        # read the genotype data from the file, selecting only the needed
        fname <- paste0("../data/", x[1,file])
        data <- fread(fname, select=c(1, x[,1+column]), skip=1)

        # rename the columns to the SNP IDs
        setnames(data, "V1", "genotype.id")
        setnames(data, paste0("V", x[,1+column]), x[,snp])

        # we read the data for all patients, so keep only those we want
        setkey(data, genotype.id)
        setkey(id.map, genotype.id)
        data <- merge(data, id.map[,"genotype.id",with=FALSE])
        
        # change the genotype IDs into project IDs
        gprojid <- data[,as.character(id.map[genotype.id, projid])]
        data[,genotype.id := NULL]

        # make a matrix with patients as rows and SNPs as columns
        data <- as.matrix(data)
        rownames(data) <- gprojid
        data
    }, simplify=FALSE))
}
