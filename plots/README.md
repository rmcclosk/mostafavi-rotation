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

__deal_qtl__: Distribution of Bayesian network topologies estimated for each
set of multi-QTL associated data. The most common topology, both in the
original and prinicipal component-reduced data, was the independence structure
with all phenotypes influenced only by genotype. The number of multi-QTLs
exhibiting this independence structure was greater in the PC-reduced data.

References
----------

[1]: [Millstein, Joshua, et al. "Disentangling molecular relationships with a
causal inference test." BMC genetics 10.1 (2009): 23.]
(http://www.biomedcentral.com/1471-2156/10/23/)
