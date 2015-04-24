plots: $(addprefix plots/,qtl_pca.png \
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
						  mediation_qtl.png \
						  datatypes_venn.png \
						  summary.png \
						  qtl_venn.png \
						  qtl_example.png \
						  deal_triples.png \
						  meqtl_pca.png \
						  cit_qtl.png)

plots/%.png: plots/%.pdf
	convert -density 150 -quality 100 $^ $@

tables/mediation_%.md plots/mediation_%.pdf: results/multi_%_data.tsv

plots/cit_qtl.pdf: utils/cit.R results/multi_qtl_data.tsv

plots/deal_triples.pdf: results/triples_data.tsv

plots/deal_qtl.pdf: results/multi_qtl_data.tsv

plots/meqtl_pca.pdf: $(QTL_BEST_PATHS)

plots/qtl_pca.pdf: $(QTL_BEST_PATHS)

plots/pca_overlap.pdf: $(QTL_BEST_PATHS)

plots/phenotypes.pdf: data/pheno_cov_n2963_092014_forPLINK.csv

plots/validate_genes.pdf: data/ROSMAP_brain_rnaseq_best_eQTL.txt $(addprefix results/eQTL/,$(QTL_BEST_FILES))

plots/validate_snps.pdf: data/ROSMAP_brain_rnaseq_best_eQTL.txt $(addprefix results/eQTL/,$(QTL_BEST_FILES))

plots/deal_phenotypes.pdf: data/patients.tsv

plots/datatypes_venn.pdf: data/patients.tsv

plots/qtl_venn.pdf: $(QTL_BEST_PATHS)

plots/qtl_example.pdf: results/multi_qtl_data.tsv

plots/deal_modules.pdf: data/module_means_filtered_byphenotype.txt

plots/deal%.pdf: utils/deal.R

# qtl_overlap.pdf and tables/qtl_overlap.md
plots/qtl_%.pdf tables/qtl_%.md: scripts/qtl_%.R $(QTL_BEST_PATHS)
	$(word 1, $^)

# scripts which produce more than one output
plots/%.pdf tables/%.md: scripts/%.R
	$(word 1, $^) --args $(shell echo $$LSB_DJOB_NUMPROC)
	pdfcrop $(word 1, $@) $(word 1, $@)
