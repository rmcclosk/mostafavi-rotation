# This Makefile shows all the dependencies of scripts upon data files, utility
# functions, and other scripts.

scripts/genotype_manifest.R: data/transposed_1kG

scripts/patients.R: data/pheno_cov_n2963_092014_forPLINK.csv \
					data/phenotype_740qc_finalFromLori.txt \
					data/techvars_plus_phenotypes26SEP2014.txt \
					data/chipSeqResiduals.csv \
					data/residual_gene_expression_expressed_genes_2FPKM100ind.txt \
					data/ill450kMeth_all_740_imputed.txt data/transposed_1kG

scripts/qtl_table.R: utils/misc.R

scripts/eQTL.R scripts/meQTL.R scripts/aceQTL.R: utils/load_data.R utils/QTL-common.R

scripts/multi_qtl_data.R: utils/misc.R utils/load_data.R
	
scripts/pairs.R: utils/load_data.R utils/QTL-common.R

scripts/deal%.R: utils/deal.R

scripts/mediation_qtl.R: utils/causal.R

scripts/cgb%.m: $(CGB_UTILS)

# unless otherwise specified, everything depends on load_data.R
scripts/%.R: utils/load_data.R
