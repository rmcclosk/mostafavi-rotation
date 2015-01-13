Data
====

The following is adapted from an email from Sara Mostafavi.

Some notes:

- "residual data" means the effect of several technical confounding factor was regressed out
- each data type uses a different form of sample id, to intersect them, you need to first map ids to "projectIDs"

Data locations:

1. expression
  - residual data: `/home/unix/mostafav/projects/cogdec_mnet/expression_data/residual_gene_expression_expressed_genes_2FPKM100ind.txt`
  - read counts: `/home/unix/mostafav/projects/cogdec_mnet/expression_data/jishu_data/RSEM_gene_FPKM_Quantile_Combat_log2_normalized.txt`
  - ID mapping file: `/home/unix/mostafav/projects/cogdec_mnet/expression_data/IDmapping.txt`
2. methylation
  - data: `/broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/ill450kMeth_all_740_imputed.txt`
  - ID mapping file: `/broad/dejagerlab/cogdec/datasets/ROSMAP/DNA_Methylation/DNA_Methylation_Brain_DLPFC_450K/frozenDataSet/phenotype_740qc_finalFromLori.txt`
3. acetylation
  - residual data: `/broad/dejagerlab/hklein/exportSara/chipSeqResiduals.csv.gz`
  - raw count: `/broad/dejagerlab/hklein/exportSara/chipSeqCounts.csv.gz`
  - peak information: `/broad/dejagerlab/hklein/exportSara/peakInfo.csv.gz`
4. genotype
  - data folder: `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/output/combined_core`
5. phenotype and technical factors
  - additional ID mappings: `/home/unix/mostafav/projects/cogdec_mnet/phenotype_data/pheno_cov_n2963_092014_forPLINK.csv`
  - technical factors for RNA-seq data: `/home/unix/mostafav/projects/cogdec_mnet/phenotype_data/techvars_plus_phenotypes26SEP2014.txt`
