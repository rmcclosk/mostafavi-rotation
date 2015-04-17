# This Makefile contains all the targets for the tables/ directory
#
# Several of the tables listed here are created by scripts which also create
# plots. The rules to make them are therefore in plots.mk instead of here.

tables: $(addprefix tables/,qtl_table.md \
						 	pair_table.md \
							missing.md \
							qtl_overlap.md \
							mediation_qtl.md)

tables/qtl_table.md: scripts/qtl_table.R $(foreach DIR, $(QTL_FOLDERS), $(DIR)/PC0.tsv $(DIR)/PC0.best.tsv $(DIR)/PC0.nocov.best.tsv)
	$(word 1, $^) > $@

tables/pair_table.md: scripts/pair_table.R $(PAIR_BEST_FILES)
	$(word 1, $^) > $@

# catch-all for scripts which don't depend on any other results files
tables/%.md: scripts/%.R
	$^ > $@
