all: db.sqlite

db.sqlite: import.py create_db.sql methylation expression acetylation phenotype reference
	rm -f $@
	sqlite3 $@ < create_db.sql
	./import.py

methylation: ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt

expression: residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt

acetylation: chipSeqResiduals.csv peakInfo.csv

phenotype: pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt

reference: ensGene.txt wgEncodeHaibMethyl450CpgIslandDetails.txt chromInfo.txt ensemblToGeneName.txt

ill450kMeth_all_740_imputed.txt phenotype_740qc_finalFromLori.txt: 
	ln -s /broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/$@ .

residual_gene_expression_expressed_genes_2FPKM100ind.txt IDmapping.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/expression_data/$@ .

chipSeqResiduals.csv peakInfo.csv:
	cp /broad/dejagerlab/hklein/exportSara/$@.gz .
	gunzip $@.gz

pheno_cov_n2963_092014_forPLINK.csv techvars_plus_phenotypes26SEP2014.txt:
	ln -s /home/unix/mostafav/projects/cogdec_mnet/phenotype_data/$@ .

ensGene.txt chromInfo.txt ensemblToGeneName.txt:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Homo_sapiens/database/$@.gz
	gunzip $@.gz

wgEncodeHaibMethyl450CpgIslandDetails.txt:
	wget ftp://hgdownload.cse.ucsc.edu/goldenPath/currentGenomes/Homo_sapiens/encodeDCC/wgEncodeHaibMethyl450/supplemental/$@
