#!/usr/bin/env Rscript

sink("/dev/null")
library(knitr)
source(file=file.path("utils", "load_data.R"))

# we can't use load.adata() because we don't want to na.omit
afile <- file.path("data", "chipSeqResiduals.csv")
adata <- fread(afile, select=1:5, showProgress=FALSE, verbose=FALSE)
adata[,feature := as.integer(sub("peak", "", V1))]
setkey(adata, feature)

peaks <- setkey(load.peaks(), feature)
adata <- merge(adata, peaks[,"feature",with=FALSE])
rm(peaks)

tbl <- data.frame(acetylation=c(nrow(adata), nrow(adata) - nrow(na.omit(adata))))

rm(adata)

manifest <- setkey(load.manifest(), snp)
snps <- setkey(load.snps(), snp)
manifest <- manifest[snps]

rm(snps)

tbl$genotype <- c(nrow(manifest), sum(is.na(manifest[,file])))

rm(manifest)

patients <- load.patients()
mfile <- file.path("data", "ill450kMeth_all_740_imputed.txt")
mdata <- fread(mfile, skip=1, select=1:2, showProgress=FALSE, verbose=FALSE)
setnames(mdata, "V1", "feature")
setkey(mdata, feature)
cpgs <- setkey(load.cpgs(), feature)

mdata <- mdata[cpgs]

tbl$methylation <- c(nrow(mdata), sum(is.na(mdata[,V2])))

rownames(tbl) <- c("features on manifest", "features missing")

sink()
kable(tbl, "markdown")
