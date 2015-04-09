primary
=======

This folder contains the most basic QTL analyses.

__QTL-common.R__: common framework for finding QTLs, used by all three
datatype-specific scripts (see below). Uses MatrixEQTL.

__eQTL.R, meQTL.R, aceQTL.R__: specific scripts which load the data for each
individual data type, and then run QTL analysis.

__eQTL/chrN.tsv, meQTL/chrN.tsv, aceQTL/chrN.tsv__: all QTL associations for
each chromosome. Note that these are not FDR corrected, and all the possible
associations are in these files regardless of statistical significance. That
is, there is one line in one of these files for each feature/SNP pair within
100 KB.

__eQTL/best.tsv, meQTL/best.tsv, aceQTL/best.tsv__: these files contain one SNP
per feature, namely the one with the lowest p-value. Every feature is
represented in these files, regardless of statistical significance. There may
be more than one entry per feature if removing principal components changed
which SNP was the best one for that feature. To get the best SNP per feature
for the data with 10 PCs removed, sort the file by `feature` and
`adj.p.value.PC10`, and take the first line for each feature.

__qtl_table.R__: prints a table in markdown format with some basic information
about the number of features and QTLs found.

__qvalue.R__: calculates adjusted P-values and q-values for each gene, and
records the best SNP per gene to produce the *QTL/best.tsv files. The adjusted
P-values and q-values are calculated for each set of P-values in the
*QTL/chrN.tsv files, that is, for the unedited data, with and without
covariates, and for the data with the first 1-20 principal components removed.

__multi_qtl.R__: finds all of the SNPs which are the best QTL for at least one
feature from all three data types. This is done according to one specific set
of P-values, which is hard coded into the file. As of this writing, it is using
the P-values from the data with the first 10 principal components removed, for
all three data types. It produces multi_qtl.tsv.

__multi_qtl.tsv__: a list of all multi-QTL quadruples (ie. SNP = "snp", gene =
"feature.e", CpG = "feature.me", CHiP-seq peak = "feature.ace"). The numbers in
the snp column are dbSNP RSIDs, without the "rs" predix. The numbers in the
"feature.e" column are Ensembl IDs, without the ENSG0...0 prefix. The strings
in the "feature.me" column are Illumina CpG identifiers (see ../data/cpg.txt).
Finally, the numbers in the "feature.ace" column are CHiP-seq peak numbers (see
../data/peak.txt).

__multi_qtl_data.R__: for each of the quadruples in multi_qtl.tsv, this script
pulls the original data and writes it together in a convenient format
(multi_qtl_data.tsv).

__multi_qtl_data.tsv__: this is the raw data for only the data associated with
each multi-QTL. The first five columns are the same as they are in
multi_qtl.tsv. The last four (g, e, me, ace) are the data values. The data
values have been adjusted in the same way they were to find the multi-QTLs in
the first place. As of this writing, this is by removing the first 10 principal
components.
