data
====

This folder contains all the raw data used for this project.

__allrevcoded.csv__: result of a clustering analysis on genes. Two columns, the
first column in the gene, and the second column in the cluster or "module"
number it has been assigned to. The clusters are allowed to overlap, and a few
genes have been assigned to multiple modules.

__chipSeqResiduals.csv.gz__: histone acetylation data. Rows are CHiP-seq peaks
(see peakInfo.csv.gz), and columns are patients. The patient IDs are the same
as the project IDs from the master phenotypes file
(pheno_cov_n2963_092014_forPLINK.csv).

__cpg.txt__: CpG probe locations in hg38 co-ordinates, which have been
lifted over from wgEncodeHaibMethyl450CpgIslandDetails.txt.gz.

__ensemblGenes.tsv__: A list of Ensembl genes. The columns are Ensembl ID, gene
name, chromosome, start position, end position, and orientation (forward=TRUE,
reverse=FALSE). The TSS can be obtained by taking the start position if the
orientation is forward, otherwise the end position.

__genotype_manifest.tsv__: Manifest of which SNPs are found in which files.

__ill450kMeth_all_740_imputed.txt__: Methylation data. The rows are CpG sites
(see cpg.txt.gz), and columns are patient IDs. The patient IDs can be mapped to
project IDs using the phenotypes file. They are the "FID" column.

__module_means_filtered_byphenotype.txt__: Mean gene expression values for each
gene module (see allrevcoded.csv). The rows are patient IDs (the number before
the colon is the project ID, see pheno_cov_n2963_092014_forPLINK.csv), and the
columns are the modules (see allrevcoded.csv).

__patients.tsv__: Merged data from all the phenotypes files, giving precedence
to newer data.

__peak.txt__: Start and end locations for CHiP-seq peaks, which have been
lifted over to hg38 co-ordinates from
`/broad/dejagerlab/hklein/exportChIPSeq/peakInfo.csv.gz`.

__pheno_cov_n2963_092014_forPLINK.csv__: Clinical data for all patients in the
project. The master ID is the "projid" column.

__phenotype_740qc_finalFromLori.txt__: An older phenotypes file, which maps the
patient IDs from the methylation experiments (see
ill450kMeth_all_740_imputed.txt) to project IDs.

__residual_gene_expression_expressed_genes_2FPKM100ind.txt__: Gene expression
data. Columns are patient IDs (the number before the colon is the project ID,
see pheno_cov_n2963_092014_forPLINK.csv), and the rows are genes (see
ensemblGenes.tsv).

__ROSMAP_brain_rnaseq_best_eQTL.txt__: Results from a separate eQTL analysis,
containing the best eQTL found for each gene. Columns are mostly
self-explanatory. The PERMUTATIONP column is a p-value corrected for the number
of comparisons made per gene.

__sign_modules_celltypes_PC_Rosemary.txt__: I'm not actually sure what this is.
Sara asked me to do a Bayes net analysis on it.

__snp.txtz__: Affy 6 SNPs which have been lifted over to hg38 co-ordinates
from snpArrayAffy6.txt.gz.

__techvars_plus_phenotypes26SEP2014.txt__: Technical variables related to
RNA-seq data. Currently unused.

__transposed_1kG__: Genotype data, contained in the *trans.txt files. These are
a subset of the original and imputed SNPs from Affy 6 array experiments, which
had good imputation quality and mutant allele frequency of at least 1%. They
are broken up into chunks of 10000 SNPs each. The files are space-delimited.
Rows are patients, and columns are SNPs. The patient IDs are the same as the
project IDs in the master phenotypes file (pheno_cov_n2963_092014_forPLINK.csv)
when the "ROS" or "MAP" prefix is removed.
