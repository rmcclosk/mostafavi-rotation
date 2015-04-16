Rotation with the Mostafavi lab
===============================

This is the repository for Rosemary McCloskey's Spring 2015 rotation project
with Sara Mostafavi.

The entire project is run using a Makefile. It's called GNUmakefile because I
make heavy use of pattern rules, which are a GNU make extension. The main
GNUmakefile sources several other makefiles, each with the suffix `.mk`, in the
root directory. These are generally responsible for the files in the directory
of the same name.

To see all the commands which were used in the project, type `make -nB` into
the terminal. Some of these commands (the ones which create a symlink) won't
work if you try to run them again, because the symlink is already there. Also,
a couple of the data files were sent to me in an email, so these cannot be
remade.

This repository is organized into a series of folders.

__data__ contains all the raw data.

__scripts__ contains all the top-level scripts used to generate results and
plots.

__utils__ contains library functions and utilities that are called by scripts.

__results__ contains unprocessed results (mostly in TSV format), such as lists
of all QTLs.

__plots__ and __tables__ contain figures and summary tables.

__cache__ is used to store `.RData` files so that scripts can be run more
quickly subsequent times. If anything in the data changes, these files will
need to be manually deleted so that scripts won't use old versions of data.

__doc__ contains presentation material.

Data
====

The following is adapted from an email from Sara Mostafavi.

Some notes:

- "residual data" means the effect of several technical confounding factor was
  regressed out
- each data type uses a different form of sample id, to intersect them, you
  need to first map ids to "projectIDs"

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
4. genotype (see below)
  - data folder: `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/output/combined_core`
5. phenotype and technical factors
  - additional ID mappings: `/home/unix/mostafav/projects/cogdec_mnet/phenotype_data/pheno_cov_n2963_092014_forPLINK.csv`
  - technical factors for RNA-seq data: `/home/unix/mostafav/projects/cogdec_mnet/phenotype_data/techvars_plus_phenotypes26SEP2014.txt`

Expression data
---------------

The residual data is a TSV file, where the rows are patients and the columns are genes. 

Genotype data
-------------

The following is adapted from an email from Charles White
<cwhite32@partners.org>.

Plink formatted gprob and dosage data here (imputed from the Affy 6 chip): `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/output/combined_core/`

How to load the data into plink:
```
/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/output/combined_core/chr$i.list sepheader format=3 Z list --fam /broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/output/combined_core/inputALL.fam
```

Plink formatted gprob data for those imputed from the Illumina omni express chip: `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20121011/output/combined_core/`

How to load the data into plink:
```
/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20121011/output/combined_core/chr$i.dosage.1.gz format=1 Z --fam /broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20121011/input/gwasFinal1Kr_1_chr$i.fam
```

Both of these include the 31 million or so 1000G SNPs.

For some custom GWAS the data has been transformed into a format better suited
to R (about 7 million SNPs with good imputation scores and MAF > .01). These
are broken into chunks of 10000 SNPs each, where the SNPs are columns and ids
are rows. There can be found here:

- affy dosages: `/broad/dejagerlab/cogdec/GWAS/ROSMAP/scripts/reformat_dosage_1kg_all_chrs/transposed_1kG/chr${CHR}`
- omni dosages: `/broad/dejagerlab/cogdec/GWAS/ROSMAP/scripts/reformat_dosage_1kg_all_chrs_newCHOP/transposed_1kG/chr${CHR}`

Actual genotypes from the chips:

- n1709, affy 6 chip: `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20101123/gwasFinal1Kr*`
- newCHOP, illumina omni chip: `/broad/dejagerlab/cogdec/datasets/ROSMAP/imputation_20121011/finals/gwasFinal1Kr*`
