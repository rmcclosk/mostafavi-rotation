#!/usr/bin/env Rscript

library(RPostgreSQL)
library(VennDiagram)
library(RColorBrewer)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="cogdec")

mquery <- paste("SELECT distinct patient_id FROM methylation_chr22")
mpatients <- dbGetQuery(con, mquery)$patient_id

aquery <- paste("SELECT distinct patient_id FROM acetylation_chr22")
apatients <- dbGetQuery(con, aquery)$patient_id

equery <- paste("SELECT distinct patient_id FROM expression_chr22")
epatients <- dbGetQuery(con, equery)$patient_id

dbDisconnect(con)

png("datatypes_venn.png")
draw.triple.venn(
    length(mpatients), 
    length(apatients), 
    length(epatients),
    length(intersect(mpatients, apatients)),
    length(intersect(apatients, epatients)),
    length(intersect(mpatients, epatients)),
    length(intersect(intersect(apatients, mpatients), epatients)),
    category=c("methylation", "acetylation", "expression"),
    col=brewer.pal(3, "Set2")
)


dev.off()
