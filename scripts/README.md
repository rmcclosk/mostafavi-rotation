Scripts
=======

This folder contains most of the the code written for this project. These
scripts generate either data files, results files, plots, or tables.

__cit_qtl.R__: Runs the Millstein et al. causal inference test (see the script
for the reference) on the multi-QTL associated data, and plots the results.

__count_features.R__: Does a basic count of the number of features tested for
each data type.

__datatypes_venn.R__: Creates a Venn diagram of the number of patients with
each type of molecular data.

__deal_modules.R__: Runs deal to infer a Bayesian network for 11 gene modules
and 5 phenotypes, and plots the resulting network.

__deal_phenotypes.R__: Creates a Bayesian network for 5 important phenotypes
using deal. The networks are visualized in plots/deal_phenotypes.pdf.

__deal_qtl.R__: Infers one Bayesian network for each set of multi-QTL
associated features by exhaustive search, and plots a histogram of the
topologies.

__ensemblGenes.pl__: Perl script to create data/ensemblGenes.tsv using the
Ensembl API.

__eQTL.R, meQTL.R, aceQTL.R__: Compute all cis-QTL correlations (not just
significant ones), for various numbers of removed principal components, and
stores the results in results/*QTL/*.tsv.

__genotype_manifest.R__: Creates data/genotype_manifest.tsv, which is a list of
which SNPs can be found in which files.

__infogeo_phenotypes.R__: Uses the information geometric causal inference test
from Janzing et al. to rule out causal relationships among three continuous
phenotypes.

__mediation_qtl.R__: Performs mediation analysis for each pair of features
associated with a multi-QTL, and creates a table of the percentage of pairs
where a significant mediating effect is observed.

__meqtl_pca.R__: Computes correlations between each poly-meQTL and the first PC
of the CpGs to which it is associated. Compares these correlations to the
individual meQTL-CpG correlations in a scatterplot.

__missing.R__: Find the number of features of each data type which are missing
from the platform's manifest, and display the results in a table.

__multi_qtl_data.R__: Get the data for each feature associated with a multiQTL,
and store the result in results/multi_qtl_data.tsv.

__multi_qtl.R__: Find a set of multi-QTLs by intersecting the sets of eQTLs,
aceQTLs, and meQTLs. Store the results in results/multi_qtl.tsv.

__non_int_patients.R__: Creates plots/non_int_patients.pdf, which shows the 
distribution of non-integer counts by SNP among patients (like above, except
instead of counts of patients per SNP, it's counts of SNPs per patient).

__non_int_snps.R__: Creates plots/non_int_snps.pdf, which shows the
distribution of non-integer counts among SNPs on the Affy6 array manifest.

__pairs_qvalue.R__: Finds the best pairs of correlated features, and computes
q-values for the number of features tested. The results are stored in
results/pairs/*.tsv.

__pairs.R__: Compute all pairwise correlations among non-genomic data types,
and store the results in results/ace_e_pairs.tsv, results/ace_me_pairs.tsv, and
results/e_me_pairs.tsv. This takes a LOT of memory, you'll need to either run
it on a cluster or modify the code to process the data in chunks.

__pair_table.R__: Creates a table of the number of features of each data type
which were significantly associated with a feature of another data type, as
tables/pair_table.md.

__patients.R__: Creates data/patients.tsv, which is a compiled list of patients
phenotypes.

__pca_overlap.R__: Creates plots/pca_overlap.pdf, which shows the number of
features gained and lost with each subsequent principal component removed.

__phenotypes.R__: Creates plots/phenotypes.pdf, which is a pairwise plot of 5
important phenotypes, as well as plots/phenotypes/*.pdf, which are density
plots of the 3 continuous phenotypes out of these 5.

__qvalue.R__: Finds the best QTL for each genomic feature, computes q-values,
and outputs the result to results/*QTL/*best.tsv.

__qtl_example.R__: Creates plots/qtl_example.pdf, which shows an example of a
multi-QTL and how it is correlated with all three molecular data types.

__qtl_overlap.R__: Creates plots/qtl_overlap.pdf, plots/*qtl_venn.pdf, and
tables/qtl_overlap.md. These all quantify the proportion of overlapping QTLs
by pi1, that is, by applying the two step multiple testing procedure. 

__qtl_pca.R__: Creates plots/qtl_pca.pdf, which shows the number of new QTLs
discovered with each principal component removed.

__qtl_table.R__: Creates tables/qtl_table.md, which gives some general
statistics about the number of tests done and QTLs discovered.

__qtl_venn.R__: Creates a Venn diagram showing the overlap between the eQTLs,
meQTLs, and aceQTLs, as plots/qtl_venn.pdf.

__summary.R__: Plots summary statistics (min, mean, median, IQR, max) of each
data type as plots/summary.pdf.

__triples_data.R__: Collects the data, both original and PC10-reduced,
associated to each correlated triple, and stores the results as
results/triples_data.tsv.

__triples.R__: Finds all correlated triples of molecular data types, and stores
them in results/triples.tsv.

__validate_genes.R__: Creates plots/validate_genes.pdf, which is a Venn diagram
of our discovered eQTL-associated genes vs. those discovered by the ROSMAP study.

__validate_snps.R__: Creates plots/validate_snps.pdf, which shows the P-value
of correlation between our identified eQTL SNPs, and those identified by the
ROSMAP study, for the same genes.
