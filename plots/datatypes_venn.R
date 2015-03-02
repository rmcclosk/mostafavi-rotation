#!/usr/bin/env Rscript

library(data.table)
library(VennDiagram)
library(RColorBrewer)

efile <- "../data/residual_gene_expression_expressed_genes_2FPKM100ind.txt"
afile <- "../data/chipSeqResiduals.csv"
mfile <- "../data/ill450kMeth_all_740_imputed.txt"
pfile <- "../data/phenotype_740qc_finalFromLori.txt"

id.map <- fread(pfile, select=c("Sample_ID", "projid"), 
                colClasses=list(character="projid"))
setkey(id.map, Sample_ID)

epatients <- fread(efile, select=1)[,gsub(":.*", "", V1)]
apatients <- colnames(fread(afile, nrows=0, skip=0))
mpatients <- colnames(fread(mfile, nrows=0, skip=0))
mpatients <- id.map[mpatients[2:length(mpatients)],projid]

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
