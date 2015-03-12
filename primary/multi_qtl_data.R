#!/usr/bin/env Rscript

library(reshape2)
library(data.table)

rm.pcs <- function (data, n.pcs) {
    s <- svd(data, nu=n.pcs, nv=n.pcs)
    res <- data - s$u %*% diag(s$d[1:n.pcs]) %*% t(s$v)
    dimnames(res) <- dimnames(data)
    res
}

multi.qtls <- fread("multi_qtl.tsv", 
                    select=c("snp", "feature.e", "feature.ace", "feature.me"))
setkey(multi.qtls, snp)

id.vars <- c("projid", "genotype.id", "expression.id", "methylation.id")
patient <- fread("../data/patients.tsv", select=c(id.vars, "use.for.qtl"))
patient <- patient[which(use.for.qtl),]

# read methylation data
read.mdata <- function () {
    mfile <- "../data/ill450kMeth_all_740_imputed.txt"
    mpatient <- tail(strsplit(readLines(mfile, n=1), "\t")[[1]], -1)
    idx <- which(mpatient %in% patient[,methylation.id])
    
    mdata <- fread(mfile, select=c(1, 1+idx), skip=1)
    setnames(mdata, "V1", "feature.me")
    setkey(patient, methylation.id)
    setnames(mdata, paste0("V", 1+idx), as.character(patient[mpatient[idx], projid]))
    setkey(mdata, feature.me)
    setcolorder(mdata, c("feature.me", as.character(sort(as.integer(tail(colnames(mdata), -1))))))
    
    mfeature <- mdata[,feature.me]
    mdata <- scale(t(mdata[,feature.me := NULL]))
    colnames(mdata) <- mfeature
    mdata <- rm.pcs(mdata, 10)
    mpatient <- rownames(mdata)
    mdata <- as.data.table(mdata)
    mdata[,projid := mpatient]
    setcolorder(mdata, c("projid", head(colnames(mdata), -1)))

    keep.cols <- which(colnames(mdata) %in% multi.qtls[,feature.me])
    mdata <- mdata[,c(1, keep.cols), with=FALSE]
    melt(mdata, id.vars="projid", variable.name="feature.me", value.name="me", variable.factor=FALSE)
}

# read acetylation data
read.adata <- function () {
    afile <- "../data/chipSeqResiduals.csv"
    apatients <- as.integer(strsplit(gsub('"', "", readLines(afile, n=1)), "\t")[[1]])
    idx <- which(apatients %in% patient[,projid])
    
    adata <- na.omit(fread(afile, skip=1, select=c(1, 1+idx)))
    setnames(adata, "V1", "feature.ace")
    setnames(adata, paste0("V", 1+idx), as.character(apatients[idx]))
    adata[,feature.ace := as.integer(sub("peak", "", feature.ace))]
    setkey(adata, feature.ace)
    
    afeature <- adata[,feature.ace]
    adata <- scale(t(adata[,feature.ace := NULL]))
    colnames(adata) <- afeature
    adata <- rm.pcs(adata, 10)
    apatient <- rownames(adata)
    adata <- as.data.table(adata)
    adata[,projid := apatient]
    setcolorder(adata, c("projid", head(colnames(adata), -1)))
    
    keep.cols <- which(colnames(adata) %in% multi.qtls[,feature.ace])
    adata <- adata[,c(1, keep.cols), with=FALSE]
    adata <- melt(adata, id.vars="projid", variable.name="feature.ace", value.name="ace", variable.factor=FALSE)
    adata[,feature.ace := as.integer(feature.ace)]
}

# read gene expression data
read.edata <- function () {
    efile <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
    efeature <- tail(strsplit(readLines(efile, n=1), "\t")[[1]], -1)
    efeature <- as.integer(gsub(".*:ENSG|[.].*", "", efeature))
    edata <- fread(efile, skip=1)
    
    setnames(edata, "V1", "expression.id")
    setnames(edata, paste0("V", 2:ncol(edata)), as.character(efeature))
    
    setkey(patient, expression.id)
    setkey(edata, expression.id)
    edata <- merge(edata, patient[,"expression.id", with=FALSE])
    edata[,expression.id := patient[expression.id, projid]]
    setnames(edata, "expression.id", "projid")
    setkey(edata, projid)
    
    eprojid <- edata[,projid]
    edata <- scale(as.matrix(edata[,projid := NULL]))
    rownames(edata) <- eprojid
    edata <- rm.pcs(edata, 10)
    epatient <- rownames(edata)
    edata <- as.data.table(edata)
    edata[,projid := epatient]
    setcolorder(edata, c("projid", head(colnames(edata), -1)))
    
    keep.cols <- which(as.integer(colnames(edata)) %in% multi.qtls[,feature.e])
    edata <- edata[,c(1, keep.cols), with=FALSE]
    edata <- melt(edata, id.vars="projid", variable.name="feature.e", value.name="e", variable.factor=FALSE)
    edata[,feature.e := as.integer(feature.e)]
}

# read genotype data
read.gdata <- function () {
    manifest <- fread("../data/genotype_manifest.tsv")
    setkey(manifest, snp)
    manifest <- merge(manifest, multi.qtls[,"snp",with=FALSE])
    setkey(manifest, file, column)
    
    cat("Reading genotype data\n")
    gdata <- rbindlist(by(manifest, manifest[,file], function (x) {
        fname <- paste0("../data/", x[1,file])
        print(fname)
        data <- fread(fname, select=c(1, x[,1+column]), skip=1)
        setnames(data, "V1", "genotype.id")
        setnames(data, paste0("V", x[,1+column]), as.character(x[,snp]))
        setkey(data, "genotype.id")
        setkey(patient, "genotype.id")
        data <- merge(data, patient[,"genotype.id",with=FALSE])
        data[,genotype.id := as.character(patient[genotype.id, projid])]
        setnames(data, "genotype.id", "projid")
        melt(data, id.vars="projid", variable.name="snp", value.name="g", variable.factor=FALSE)
    }, simplify=FALSE))
    gdata[,snp := as.integer(snp)]
}

edata <- setkey(read.edata(), feature.e)
setkey(multi.qtls, feature.e)
data <- merge(edata, multi.qtls, allow.cartesian=TRUE)

setkey(data, projid, feature.ace)
adata <- setkey(read.adata(), projid, feature.ace)
data <- merge(data, adata)

setkey(data, projid, feature.me)
mdata <- setkey(read.mdata(), projid, feature.me)
data <- merge(data, mdata)

setkey(data, projid, snp)
gdata <- setkey(read.gdata(), projid, snp)
data <- merge(data, gdata)
data

write.table(data, "multi_qtl_data.tsv", col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
