scripts
=======

This folder contains all the top-level code written for this project.

__ensemblGenes.pl__: Perl script to create data/ensemblGenes.tsv using the
Ensembl API.

__genotype_manifest.R__: Creates data/genotype_manifest.tsv, which is a list of
which SNPs can be found in which files.

__patients.R__: Creates data/patients.tsv, which is a compiled list of patients
phenotypes.

__eQTL.R, meQTL.R, aceQTL.R__: Compute all cis-QTL correlations (not just
significant ones), for various numbers of removed principal components, and
stores the results in results/*QTL/*.tsv.

__qvalue.R__: Finds the best QTL for each genomic feature, computes q-values,
and outputs the result to results/*QTL/*best.tsv.

__qtl_table.R__: Creates tables/qtl_table.md, which gives some general
statistics about the number of tests done and QTLs discovered.

__qtl_pca.R__: Creates plots/qtl_pca.png, which shows the number of new QTLs
discovered with each principal component removed.

__validate_genes.R__: Creates plots/validate_genes.png, which is a Venn diagram
of our discovered eQTL-associated genes vs. those discovered by the ROSMAP study.

__validate_snps.R__: Creates plots/validate_snps.png, which shows the P-value
of correlation between our identified eQTL SNPs, and those identified by the
ROSMAP study, for the same genes.

__multi_qtl_data.R__: Get the data for each feature associated with a multiQTL,
and store the result in results/multi_qtl_data.tsv.

__pairs.R__: Compute all pairwise correlations among non-genomic data types,
and store the results in results/ace_e_pairs.tsv, results/ace_me_pairs.tsv, and
results/e_me_pairs.tsv. This takes a LOT of memory, you'll need to either run
it on a cluster or modify the code to process the data in chunks.

__pairs_qvalue.R__: Use the two-step multiple test correction approach to get
the most significant correlations per feature for each pair of data types.
Store the results in results/pairs/*.tsv.

__pca_overlap.R__: Creates plots/pca_overlap.png, which shows the number of
features gained and lost with each subsequent principal component removed.

__phenotypes.R__: Creates plots/phenotypes.png, which is a pairwise plot of 5
important phenotypes, as well as plots/phenotypes/*.png, which are density
plots of the 3 continuous phenotypes out of these 5.

__multi_qtl.R__: Find a set of multi-QTLs by intersecting the sets of eQTLs,
aceQTLs, and meQTLs. Store the results in results/multi_qtl.tsv.

__pair_table.R__: Creates tables/pair_table.md, which gives the number of
significantly correlated features between each pair of data types.

__qtl_overlap.R__: Creates plots/qtl_overlap.png, plots/*qtl_venn.png, and
tables/qtl_overlap.md. These all quantify the proportion of overlapping QTLs
by pi1, that is, by applying the two step multiple testing procedure. 

__non_int_snps.R__: Creates plots/non_int_snps.png, which shows the
distribution of non-integer counts among SNPs on the Affy6 array manifest.

__non_int_patients.R__: Creates plots/non_int_patients.png, which shows the 
distribution of non-integer counts by SNP among patients (like above, except
instead of counts of patients per SNP, it's counts of SNPs per patient).

__deal_phenotypes.R__: Creates a Bayesian network for 5 important phenotypes
using deal. The networks are visualized in plots/deal_phenotypes.png.
