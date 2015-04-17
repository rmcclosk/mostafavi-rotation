plots: $(addprefix plots/,qtl_pca.png \
						  phenotypes.png \
						  phenotypes/amyloid_sqrt.png \
						  phenotypes/globcog_random_slope.png \
						  phenotypes/tangles_sqrt.png \
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

plots/compare_modules.png: results/compare_modules.gv
	dot -Tpng $^ > $@

plots/deal_qtl.png: scripts/deal_qtl.R utils/deal.R results/multi_qtl_data.tsv
	$(word 1, $^)

plots/cgb_qtl.png: scripts/cgb_qtl.m $(CGB_UTILS) results/multi_qtl_data.tsv
	matlab -nodisplay -singleCompThread < $(word 1, $^)

plots/qtl_pca.png: scripts/qtl_pca.R $(QTL_BEST_PATHS)
	$(word 1, $^)

plots/pca_overlap.png: scripts/pca_overlap.R $(QTL_BEST_PATHS)
	$(word 1, $^)

plots/validate_genes.png: scripts/validate_genes.R data/ROSMAP_brain_rnaseq_best_eQTL.txt $(addprefix results/eQTL/,$(QTL_BEST_FILES))
	$(word 1, $^)

plots/validate_snps.png: scripts/validate_snps.R data/ROSMAP_brain_rnaseq_best_eQTL.txt $(addprefix results/eQTL/,$(QTL_BEST_FILES))
	$(word 1, $^)

plots/non_int_snps.png: scripts/non_int_snps.R $(QTL_RAW_PATHS)
	$(word 1, $^)

plots/deal_phenotypes.png: scripts/deal_phenotypes.R data/patients.tsv
	$(word 1, $^)

plots/mediation_qtl.png: scripts/mediation_qtl.R results/multi_qtl_data.tsv

# deal_modules.png and results/deal_modules.net
plots/deal%.png results/deal%.net: scripts/deal%.R data/module_means_filtered_byphenotype.txt
	$(word 1, $^)

# qtl_overlap.png and tables/qtl_overlap.md
plots/qtl_%.png tables/qtl_%.md: scripts/qtl_%.R $(QTL_BEST_PATHS)
	$(word 1, $^)

# cgb_modules.png and cgb_phenotypes.png
plots/cgb%.png: results/cgb%.gv
	dot -Tpng $^ > $@

# plots/phenotypes.png and plots/phenotypes/*.png
plots/%.png plots/%/%.png: scripts/%.R
	$^

# scripts which produce more than one output
plots/%.png tables/%.md: scripts/%.R
	$^

# catch-all for R scripts without any extra dependencies
plots/%.png: scripts/%.R
	$^
