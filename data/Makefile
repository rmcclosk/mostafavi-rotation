#all: methylation expression
all: db.sqlite

db.sqlite: refGene.txt wgEncodeHaibMethyl450CpgIslandDetails.txt import.py create_db.sql
	rm -f $@
	sqlite3 $@ < create_db.sql
	./import.py

methylation: ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt

expression: residual_gene_expression_expressed_genes_2FPKM100ind.txt

wgEncodeHaibMethyl450CpgIslandDetails.txt:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeHaibMethyl450/supplemental/$@

ill450kMeth_all_740_imputed.txt:
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

phenotype_740qc_finalFromLori.txt: 
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

residual_gene_expression_expressed_genes_2FPKM100ind.txt: 
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$@ .

refGene.txt:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/$@.gz
	gunzip $@.gz
