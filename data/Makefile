all: methylation 

methylation: wgEncodeHaibMethyl450CpgIslandDetails.txt ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt

expression: residual_gene_expression_expressed_genes_2FPKM100ind.txt knownGene.txt.gz

wgEncodeHaibMethyl450CpgIslandDetails.txt:
	wget -qO- ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeHaibMethyl450/supplemental/wgEncodeHaibMethyl450CpgIslandDetails.txt | grep '^c[gh]' > $@

ill450kMeth_all_740_imputed.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/ill450kMeth_all_740_imputed.txt .

phenotype_740qc_finalFromLori.txt: 
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/phenotype_740qc_finalFromLori.txt .

residual_gene_expression_expressed_genes_2FPKM100ind.txt: 
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/residual_gene_expression_expressed_genes_2FPKM100ind.txt .

knownGene.txt.gz: 
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/knownGene.txt.gz
