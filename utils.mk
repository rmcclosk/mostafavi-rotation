# This Makefile records the dependencies of utility files.

utils/load_data.R: data/patients.tsv \
	               data/ill450kMeth_all_740_imputed.txt \
				   data/chipSeqResiduals.csv \
    			   data/residual_gene_expression_expressed_genes_2FPKM100ind.txt \
    			   data/genotype_manifest.tsv \
				   data/transposed_1kG \
				   data/snp.txt \
				   data/cpg.txt \
				   data/peak.txt \
				   data/ensemblGenes.tsv
