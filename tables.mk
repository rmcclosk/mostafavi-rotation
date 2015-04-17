# This Makefile contains all the targets for the tables/ directory

tables: $(addprefix tables/,qtl_table.md \
						 	pair_table.md \
							missing.md \
							qtl_overlap.md \
							mediation_qtl.md)

tables/%.md: scripts/%.R
	$^ > $@
