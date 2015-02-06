#!/usr/bin/env Rscript

library(RPostgreSQL)
library(data.table)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

query <- "SELECT patient_id, chrom, peak_start, value FROM acetylation"
data <- dbGetQuery(con, query)
dbDisconnect(con)

setDT(data)

mtx.patient <- dcast.data.table(data, chrom + peak_start ~ patient_id)[,c("chrom", "peak_start") := NULL]
pc.patient <- prcomp(mtx.patient, scale.=TRUE)

mtx.peak <- dcast.data.table(data, patient_id ~ chrom + peak_start)[, patient_id := NULL]
pc.peak <- prcomp(mtx.peak, scale.=TRUE)

png("acetylation_pca.png")
plot(pc.patient$x[1], pc.patient$x[2], main="PC of patients", xlab="PC1", ylab="PC2")
plot(pc.peak$x[1], pc.peak$x[2], main="PC of peaks", xlab="PC1", ylab="PC2")
dev.off()
