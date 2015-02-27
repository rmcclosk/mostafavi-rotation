data
====

This folder contains all the raw data used for this project, as it was
recieved. It may also contain scripts to fetch data files from an API.

__allrevcoded.csv__: result of a clustering analysis on genes. Two columns, the
first column in the gene, and the second column in the cluster or "module"
number it has been assigned to. The clusters are allowed to overlap, and a few
genes have been assigned to multiple modules.

__chipSeqResiduals.csv.gz__: histone acetylation data. Rows are CHiP-seq peaks
(see peakInfo.csv.gz), and columns are patients. The patient IDs are the same
as the project IDs from the master phenotypes file
(pheno_cov_n2963_092014_forPLINK.csv).

__chromInfo.txt.gz__: hg38 chromosome info, from UCSC. The first two columns
are chromosome and length. The last column in unused.

__cpg.txt.gz__: CpG probe locations in hg38 co-ordinates, which have been
lifted over from wgEncodeHaibMethyl450CpgIslandDetails.txt.gz.

__ensemblGenes.pl__: Perl script to create ensemblGenes.tsv using the Ensembl
API.

__ensemblGenes.tsv__: A list of Ensembl genes. The columns are Ensembl ID, gene
name, chromosome, start position, end position, and orientation (forward=TRUE,
reverse=FALSE). The TSS can be obtained by taking the start position if the
orientation is forward, otherwise the end position.

__hg19ToHg38.over.chain.gz__: LiftOver chain file to convert hg19 co-ordinates
to hg38.

__ill450kMeth_all_740_imputed.txt__: Methylation data. The rows are CpG sites
(see cpg.txt.gz), and columns are patient IDs. The patient IDs can be mapped to
project IDs using the phenotypes file. They are the "FID" column.

__module_means_filtered_byphenotype.txt__: Mean gene expression values for each
gene module (see allrevcoded.csv). The rows are patient IDs (the number before
the colon is the project ID, see pheno_cov_n2963_092014_forPLINK.csv), and the
columns are the modules (see allrevcoded.csv).

__peakInfo.csv.gz__: Start and end locations for CHiP-seq peaks, in hg19
co-ordinates. See chipSeqResiduals.csv.gz for the actual CHiP-seq data.

__peak.txt.gz__: Start and end locations for CHiP-seq peaks, which have been
lifted over to hg38 co-ordinates from peakInfo.csv.gz.

__pheno_cov_n2963_092014_forPLINK.csv__: Clinical data for all patients in the
project. The master ID is the "projid" column.

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

__snpArrayAffy6.txt.gz__: List of SNPs which are assayed on the Affy 6 chip,
and their genomic locations in hg19 co-ordinates. Columns 1, 2, and 3 give the
genomic position, and column 8 is the dbSNP identifier (RSID).

__snp.txt.gz__: Affy 6 SNPs which have been lifted over to hg38 co-ordinates
(see snpArrayAffy6.txt.gz).

__techvars_plus_phenotypes26SEP2014.txt__: Technical variables related to
RNA-seq data. Currently unused.

__transposed_1kG__: Genotype data, contained in the *trans.txt files. These are
a subset of the original and imputed SNPs from Affy 6 array experiments, which
had good imputation quality and mutant allele frequency of at least 1%. They
are broken up into chunks of 10000 SNPs each. The files are space-delimited.
Rows are patients, and columns are SNPs. The patient IDs are the same as the
project IDs in the master phenotypes file (pheno_cov_n2963_092014_forPLINK.csv)
when the "ROS" or "MAP" prefix is removed.

__wgEncodeHaibMethyl450CpgIslandDetails.txt.gz__: CpG probes used in the
Illumina 450K methylation array, with genomic locations in hg19 co-ordinates.
The header is on line 8, and the data starts on line 9.
