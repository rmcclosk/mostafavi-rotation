all: phenotypes.png densities

densities: $(patsubst %,phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)

phenotypes.png phenotypes/%.png: phenotypes.R
	./$^

eQTL_venn.png meQTL_venn.png aceQTL_venn.png: qtl_venn.R
	./$^
