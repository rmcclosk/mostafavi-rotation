results
=======

This folder contains "raw" results, mostly TSV files.

__eQTL/PCN.tsv, meQTL/PCN.tsv, aceQTL/PCN.tsv__: all QTL associations for each
data type. Note that these are not FDR corrected, and all the possible
associations are in these files regardless of statistical significance. That
is, there is one line in one of these files for each feature/SNP pair within
100 KB. The numbers in the file names refer to the number of principal
components removed from the data before the correlations were computed. The
file "PC0.nocov.tsv" was run without including any phenotypic covariates; all
others included 6 covariates (pmi, msex, age_death, EV1, EV2, EV3).

__eQTL/PCN.best.tsv, meQTL/PCN.best.tsv, aceQTL/PCN.best.tsv__: these files
contain one SNP per feature, namely the one with the lowest P-value. Every
feature is represented in these files, regardless of statistical significance,
but there is only one line per feature. These P-values have been FDR corrected
and the q-value estimates are also given in the file.

__multi_qtl.tsv__: a list of all multi-QTL quadruples (ie. SNP = "snp", gene =
"feature.e", CpG = "feature.me", CHiP-seq peak = "feature.ace"). The numbers in
the "feature.e" column are Ensembl IDs, without the ENSG0...0 prefix. The
strings in the "feature.me" column are Illumina CpG identifiers (see
data/cpg.txt).  Finally, the numbers in the "feature.ace" column are CHiP-seq
peak numbers (see data/peak.txt).

__multi_qtl_data.tsv__: this is the raw data associated with each multi-QTL.
The first five columns are the same as they are in multi_qtl.tsv. The next four
(g, e, me, ace) are the data values, which have been adjusted by removing the
first 10 principal components. The final three columns (e.orig, ace.orig,
me.orig) are the original data values without removing any PCs (although they
were normalized).
