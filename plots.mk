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
						  cgb_qtl.png \
						  mediation_qtl.png \
						  compare_modules.png)

densities: $(patsubst %,plots/phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)

plots/compare_modules.png: results/compare_modules.gv
	dot -Tpng $^ > $@

results/compare_modules.gv: utils/compare_graphs.py results/deal_modules.gv results/cgb_modules.gv
	$^ > $@

# CGBayesNets Matlab stuff
plots/cgb_qtl.png: scripts/cgb_qtl.m results/multi_qtl_data.tsv
	matlab -nodisplay -singleCompThread < $(word 1, $^)

plots/cgb%.png: results/cgb%.gv
	dot -Tpng $^ > $@

# for phenotypes.R
plots/%.png plots/%/%.png: scripts/%.R
	$^

# scripts which produce more than one output
plots/%.png tables/%.md: scripts/%.R
	$^

plots/%.png results/%.net: scripts/%.R results/multi_qtl_data.tsv
	$(word 1, $^)

# for most of the R scripts
plots/%.png: scripts/%.R
	$^

