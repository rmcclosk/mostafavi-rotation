plots: densities \
	   $(addprefix plots/,qtl_pca.png \
						  phenotypes.png \
						  pca_overlap.png \
						  validate_genes.png \
						  validate_snps.png \
						  non_int_snps.png \
						  non_int_patients.png \
	                      qtl_overlap.png \
						  deal_phenotypes.png \
						  deal_modules.png \
						  deal_qtl.png \
						  cgb_phenotypes.png \
						  cgb_modules.png \
						  cgb_qtl.png)

densities: $(patsubst %,plots/phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)

# CGBayesNets Matlab stuff
plots/cgb_qtl.png: scripts/cgb_qtl.m
	matlab -nodisplay -singleCompThread < $^

plots/cgb%.png: results/cgb%.gv
	dot -Tpng $^ > $@

# for phenotypes.R
plots/%.png plots/%/%.png: scripts/%.R
	$^

# for most of the R scripts
plots/%.png: scripts/%.R
	$^

# scripts which produce more than one output
plots/%.png tables/%.md: scripts/%.R
	$^

plots/%.png results/%.net: scripts/%.R
	$^
