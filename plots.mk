plots: densities \
	   $(addprefix plots/,qtl_pca.png \
						  phenotypes.png \
						  pca_overlap.png \
						  validate_genes.png \
						  validate_snps.png)

densities: $(patsubst %,plots/phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)

plots/%.png plots/%/%.png: scripts/%.R
	$^

plots/%.png: scripts/%.R
	$^
