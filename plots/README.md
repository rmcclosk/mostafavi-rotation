Plots
=====

This directory contains visualiations of data and results. All of the plots
here are built by a script of the same name in the scripts/ folder. If you want
to remake one of the plots, make sure you are in the project root directory,
and then type `make plots/my_plot.png`, replacing `my_plot.png` with the name
of the plot you wish to make.

The plotting scripts create graphics in both pdf format, which are later
converted to png using [ImageMagick
convert](http://www.imagemagick.org/script/convert.php). But if you just cloned
this repo, the png files would have come with it, and there won't be any pdf
files here. They can be remade with the appropriate make commands.

List of figures
---------------

I have tried to write figure legends for each figure here. For a more thorough
explanation of what these figures mean, and some context, see the (project
summary)[https://github.com/rmcclosk/mostafavi-rotation/wiki/Summary].

__cit_qtl__: The causal inference test developed by Millstein et al. [1]
indicates that mediating effects are not supported in the majority of
multi-QTL-associated feature groups.

__datatypes_venn__: The patients used for this study are a subset of a large
cohort from whom four different types of molecular data have been collected.
Our analyses are restricted to the central cell, containing patients with
complete data.

__deal_modules__: A heuristically inferred Bayesian network on eleven
predefined gene modules and five phenotypes indicates a high degree of
interconnectedness among modules, but limited connectivity between modules and
phenotypes. This suggests that only a small number of gene modules can be
directly implicated in cognitive decline.

__deal_phenotypes__: Four equivalently optimal Bayesian networks describe the
relationships between five phenotype variables important in Alzheimer's
disease. All networks agree that a diagnosis of Alzheimer's is causative of
changes in amyloid load, tangles, and cognitive decline rates, rather than the
reverse.

__deal_qtl__: Histogram of Bayesian network topologies estimated for each set
of multi-QTL associated data. The most common topology, both in the original
and prinicipal component-reduced data, was the independence structure with all
phenotypes influenced only by genotype. The number of multi-QTLs exhibiting
this independence structure was greater in the PC-reduced data.

__deal_triples__: Histogram of Bayesian network topologies estimated for each 
correlated triple of molecular featuares. No single topology is the most
common, and results vary significantly between original and PC10-reduced data.

__mediation_qtl__: Mediation analyses performed on multi-QTL-associated feature
sets shows that only a quarter of these features are involved in mediating
relationships.

__meqtl_pca__: The first principal component of CpGs associated to the same
meQTL was highly correlated to the meQTL. This correlation was generally more
significant than all but the best correlations between the meQTL and the
individual CpGs.

__non_int_patients__: The genotype data of most patients contains between 1000
and 2000 non-integer SNP values, and no patient's data contains more than 5000.
These were likely SNP calls with low quality scores which were discarded and
imputed.

__non_int_snps__: Many SNPs on the Affy 6 manifest, which should have been
directly assayed, appear imputed for a proportion of patients in the data set.
This trend also holds among only SNPs which are within cis-distance of a TSS,
CHiP-seq peak, or CpG.

__pca_overlap__: As more principal components are removed, the number of new
QTL-associated features discovered drops, while the number of features which
lose their QTL-associated status remains relatively constant.

__phenotypes__: Pairwise plots of five Alzheimer's phenotypes show expected
relationships between diagnoses, brain abnormalities, and cognitive decline.
A significant proportion of individuals positively diagnosed by a pathologist
post-mortem were never diagnosed by a physician.

__qtl_example__: An example of a SNP which is correlated with gene expression,
methylation, and acetylation.

__qtl_overlap__: The percentage of each QTL type which was discovered as
another QTL type using a two-step multiple test correction approach. There was
a relatively low overlap between aceQTLs and eQTLs; however, most eQTLs and
aceQTLs were discovered as meQTLs. 40% of meQTLs were not rediscovered by this
multiple testing approach.

__qtl_pca__: The overall number of features found to be associated with a QTL
increased with each principal component removed from the data.

__qtl_venn__: The intersection of the separately discovered eQTLs, meQTLs, and
aceQTLs contains 272 "multi-QTL" SNPs.

__summary__: Summary statistics of the molecular data indicate that prior
normalization was done on all three data types. Gene expression and acetylation
data appears to have been quantile normalized, while methylation data was
shifted and scaled so that its extreme values were 0 and 1.

__validate_genes__: The majority of QTL-associated genes in our data overlap
with genes discovered by a prior study.

__validate_snps__: For the genes discovered in both our analysis and a previous
eQTL study, the correlation between the identified SNPs for each gene is
extremely good, with a majority of p-values numerically zero.

References
----------

[1]: [Millstein, Joshua, et al. "Disentangling molecular relationships with a
causal inference test." BMC genetics 10.1 (2009): 23.]
(http://www.biomedcentral.com/1471-2156/10/23/)
