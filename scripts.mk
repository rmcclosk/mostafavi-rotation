# This Makefile shows all the dependencies of scripts upon data files, utility
# functions, and other scripts.

# QTL results
QTL_FOLDERS = $(patsubst %,results/%QTL,e ace me)
QTL_BASE = $(patsubst %,PC%,0.nocov 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
QTL_RAW = $(foreach DIR,$(QTL_FOLDERS),$(foreach BASE,$(QTL_BASE),$(DIR)/$(BASE).tsv))
QTL_BEST = $(foreach DIR,$(QTL_FOLDERS),$(foreach BASE,$(QTL_BASE),$(DIR)/$(BASE).best.tsv))

# results for other pairwise correlations
PAIRS_RAW = $(addprefix results/,ace_e_pairs.tsv ace_me_pairs.tsv e_me_pairs.tsv)

scripts/genotype_manifest.R: data/transposed_1kG

scripts/patients.R: data/pheno_cov_n2963_092014_forPLINK.csv data/phenotype_740qc_finalFromLori.txt data/techvars_plus_phenotypes26SEP2014.txt data/chipSeqResiduals.csv data/residual_gene_expression_expressed_genes_2FPKM100ind.txt data/ill450kMeth_all_740_imputed.txt data/transposed_1kG

scripts/phenotypes.R: data/pheno_cov_n2963_092014_forPLINK.csv

scripts/qtl_pca.R: $(QTL_RAW) $(QTL_BEST)

scripts/qtl_table.R: utils/misc.R $(foreach FILE,PC0.tsv PC0.best.tsv PC0.nocov.best.tsv,$(QTL_FOLDERS)/$(FILE))

scripts/pca_overlap.R: $(QTL_BEST)

scripts/validate_genes.R: data/ROSMAP_brain_rnaseq_best_eQTL.txt $(foreach BASE, $(QTL_BASE),results/eQTL/$(BASE).best.tsv)

scripts/validate_snps.R: data/ROSMAP_brain_rnaseq_best_eQTL.txt utils/load_data.R $(QTL_BEST)

scripts/pairs.R: utils/load_data.R utils/QTL-common.R

scripts/multi_qtl_data.R: results/multi_qtl.tsv utils/misc.R utils/load_data.R
	
scripts/imputation.R: utils/load_data.R

scripts/pairs_qvalue.R: $(PAIRS_RAW)

scripts/pair_table.R: utils/load_data.R

scripts/missing.R: utils/load_data.R

scripts/non_int_snps.R: utils/load_data.R $(QTL_RAW)

scripts/non_int_patients.R: utils/load_data.R
