#!/usr/bin/env Rscript

# This script gets the raw data associated with each multi-QTL. 
# The main part is at the bottom.

library(reshape2)
library(data.table)

# how many PCs to remove from each data type
me.pc <- 10
e.pc <- 10
ace.pc <- 10

# function to remove the first n principal components from the data
rm.pcs <- function (data, n.pcs) {
    s <- svd(data, nu=n.pcs, nv=n.pcs)
    res <- data - s$u %*% diag(s$d[1:n.pcs]) %*% t(s$v)
    dimnames(res) <- dimnames(data)
    res
}

# get the list of multi-QTLs
multi.qtls <- fread("multi_qtl.tsv", 
                    select=c("snp", "feature.e", "feature.ace", "feature.me"))
setkey(multi.qtls, snp)

# read the patient IDs for all the data types
id.vars <- c("projid", "genotype.id", "expression.id", "methylation.id")
patient <- fread("../data/patients.tsv", select=c(id.vars, "use.for.qtl"))
patient <- patient[which(use.for.qtl),]

# read methylation data
read.mdata <- function () {
    mfile <- "../data/ill450kMeth_all_740_imputed.txt"

    # the methylation data has patients as columns
    # find the column indices for patients we want
    mpatient <- tail(strsplit(readLines(mfile, n=1), "\t")[[1]], -1)
    idx <- which(mpatient %in% patient[,methylation.id])
    
    # read the data; first column is the CpG ID
    mdata <- fread(mfile, select=c(1, 1+idx), skip=1)
    setnames(mdata, "V1", "feature.me")

    # set the column names to the patient IDs, and put them in numerical order
    setkey(patient, methylation.id)
    setnames(mdata, paste0("V", 1+idx), as.character(patient[mpatient[idx], projid]))
    setcolorder(mdata, c("feature.me", as.character(sort(as.integer(tail(colnames(mdata), -1))))))

    # order the data by CpG, and keep track of the CpGs for later
    setkey(mdata, feature.me)
    mfeature <- mdata[,feature.me]

    # make a matrix with patients as columns and CpGs as rows
    mdata <- scale(t(mdata[,feature.me := NULL]))
    colnames(mdata) <- mfeature
    
    # remove principal components
    mdata <- rm.pcs(mdata, me.pc)

    # reform the data into a data.table, with patient ID (projid) as a column
    # instead of as row names
    mpatient <- rownames(mdata)
    mdata <- as.data.table(mdata)
    mdata[,projid := mpatient]
    setcolorder(mdata, c("projid", head(colnames(mdata), -1)))

    # keep only the CpGs which have an associated multi-QTL
    keep.cols <- which(colnames(mdata) %in% multi.qtls[,feature.me])
    mdata <- mdata[,c(1, keep.cols), with=FALSE]

    # make a long skinny data table, with columns projid (the patient ID),
    # feature.me (the CpG ID), and me (the methylation value)
    melt(mdata, id.vars="projid", variable.name="feature.me", value.name="me", variable.factor=FALSE)
}

# read acetylation data
read.adata <- function () {
    # acetylation data has peaks for rows and patients for columns
    # find the column indices of patients we want
    afile <- "../data/chipSeqResiduals.csv"
    apatients <- as.integer(strsplit(gsub('"', "", readLines(afile, n=1)), "\t")[[1]])
    idx <- which(apatients %in% patient[,projid])
    
    # read the data; the first column in the peak ID
    adata <- na.omit(fread(afile, skip=1, select=c(1, 1+idx)))
    setnames(adata, "V1", "feature.ace")
    
    # set the column names to be the patient IDs
    setnames(adata, paste0("V", 1+idx), as.character(apatients[idx]))

    # make the peak ID (eg. "peak23") into an integer (23)
    adata[,feature.ace := as.integer(sub("peak", "", feature.ace))]
    setkey(adata, feature.ace)
    
    # make a matrix with patients as columns and peaks as rows
    afeature <- adata[,feature.ace]
    adata <- scale(t(adata[,feature.ace := NULL]))
    colnames(adata) <- afeature

    # remove principal components
    adata <- rm.pcs(adata, a.pc)

    # remake into a data.table with peaks as columns and patients as rows
    apatient <- rownames(adata)
    adata <- as.data.table(adata)
    adata[,projid := apatient]
    setcolorder(adata, c("projid", head(colnames(adata), -1)))
    
    # keep only peak associated with a multi-QTL
    keep.cols <- which(colnames(adata) %in% multi.qtls[,feature.ace])
    adata <- adata[,c(1, keep.cols), with=FALSE]

    # make the data long and skinny, with columns projid (the patient ID),
    # feature.ace (the peak number), and ace (the acetylation value)
    adata <- melt(adata, id.vars="projid", variable.name="feature.ace", value.name="ace", variable.factor=FALSE)
    adata[,feature.ace := as.integer(feature.ace)]
}

# read gene expression data
read.edata <- function () {
    # the gene expression data has patients as rows and genes as columns
    efile <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"

    # get the gene IDs from the column names
    efeature <- tail(strsplit(readLines(efile, n=1), "\t")[[1]], -1)
    efeature <- as.integer(gsub(".*:ENSG|[.].*", "", efeature))
    
    # read the data, and set column names to the gene IDs
    edata <- fread(efile, skip=1)
    setnames(edata, "V1", "expression.id")
    setnames(edata, paste0("V", 2:ncol(edata)), as.character(efeature))
    
    # since we read in all the patients, delete the ones we're not using
    setkey(patient, expression.id)
    setkey(edata, expression.id)
    edata <- merge(edata, patient[,"expression.id", with=FALSE])

    # now change the IDs in the expression file into projids
    edata[,expression.id := patient[expression.id, projid]]
    setnames(edata, "expression.id", "projid")
    setkey(edata, projid)
    
    # make a matrix with patients as rows and genes as columns
    eprojid <- edata[,projid]
    edata <- scale(as.matrix(edata[,projid := NULL]))
    rownames(edata) <- eprojid
    
    # remove principal components
    edata <- rm.pcs(edata, 10)

    # reform the data into a table
    epatient <- rownames(edata)
    edata <- as.data.table(edata)
    edata[,projid := epatient]
    setcolorder(edata, c("projid", head(colnames(edata), -1)))
    
    # keep only the genes which are associated with a multi-QTL
    keep.cols <- which(as.integer(colnames(edata)) %in% multi.qtls[,feature.e])
    edata <- edata[,c(1, keep.cols), with=FALSE]

    # make the data long and skinny, with columns projid (the patient ID),
    # feature.e (the gene ID), and e (the expression value)
    edata <- melt(edata, id.vars="projid", variable.name="feature.e", value.name="e", variable.factor=FALSE)
    edata[,feature.e := as.integer(feature.e)]
}

# read genotype data
read.gdata <- function () {

    # read the manifest of which SNPs are in which files
    manifest <- fread("../data/genotype_manifest.tsv")

    # change the SNP IDs into integers by removing the "rs"
    manifest <- manifest[grepl("rs", snp),]
    manifest[,snp := as.integer(sub("rs", "", snp))]
    setkey(manifest, snp)

    # keep only the SNPs associated with a multi QTL
    manifest <- merge(manifest, multi.qtls[,"snp",with=FALSE])
    setkey(manifest, file, column)
    
    # go through each file with SNPs we need
    cat("Reading genotype data\n")
    gdata <- rbindlist(by(manifest, manifest[,file], function (x) {

        # the genotype data has patients as rows and SNPs as columns
        # read the genotype data from the file, selecting only the needed
        fname <- paste0("../data/", x[1,file])
        print(fname)
        data <- fread(fname, select=c(1, x[,1+column]), skip=1)

        # rename the columns to the SNP IDs
        setnames(data, "V1", "genotype.id")
        setnames(data, paste0("V", x[,1+column]), as.character(x[,snp]))

        # we read the data for all patients, so keep only those we want
        setkey(data, genotype.id)
        setkey(patient, genotype.id)
        data <- merge(data, patient[,"genotype.id",with=FALSE])
        data[,genotype.id := as.character(patient[genotype.id, projid])]
        setnames(data, "genotype.id", "projid")

        # make the data tall and skinny, with values projid (the patient ID),
        # snp, and g (the genotype value)
        melt(data, id.vars="projid", variable.name="snp", value.name="g", variable.factor=FALSE)
    }, simplify=FALSE))
    gdata[,snp := as.integer(snp)]
}

# read the gene expression data, and merge with the list of multi-QTLs
edata <- setkey(read.edata(), feature.e)
setkey(multi.qtls, feature.e)
data <- merge(edata, multi.qtls, allow.cartesian=TRUE)

# merge in the acetylation data
setkey(data, projid, feature.ace)
adata <- setkey(read.adata(), projid, feature.ace)
data <- merge(data, adata)

# merge in the methylation data
setkey(data, projid, feature.me)
mdata <- setkey(read.mdata(), projid, feature.me)
data <- merge(data, mdata)

# merge in the genotype data
setkey(data, projid, snp)
gdata <- setkey(read.gdata(), projid, snp)
data <- merge(data, gdata)

# finally, write everything to a file
write.table(data, "multi_qtl_data.tsv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
