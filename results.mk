# This is the Makefile for everything in the results directory, which contains
# 'raw' results (ie. tsv files).

results: results/triples_data.tsv

results/triples_data.tsv: scripts/triples_data.R results/triples.tsv
	$(word 1, $^)

results/triples.tsv: scripts/triples.R $(PAIR_BEST_PATHS)
	$(word 1, $^)

# deal_modules.gv and deal_phenotypes.gv
results/deal_%.gv: utils/net2gv.py results/deal_%.net
	$(word 1,$^) < $(word 2,$^) > $@

results/multi_qtl_data.tsv: scripts/multi_qtl_data.R results/multi_qtl.tsv
	$(word 1, $^)

# requires eQTL/*.best.tsv, meQTL/*.best.tsv, and aceQTL/*.best.tsv
results/multi_qtl.tsv: scripts/multi_qtl.R $(QTL_BEST_PATHS)
	$(word 1, $^)
	
# *QTL/PC1.best.tsv etc.
# requires the raw QTL data
# argument is directory where raw files are located (output files written to the same directory)
$(addprefix results/%QTL/, $(QTL_BEST_FILES)): scripts/qvalue.R $(addprefix results/%QTL/, $(QTL_RAW_FILES))
	$(word 1, $^) --args $(dir $@)

# eQTL/PC1.tsv etc.
# argument to script is number of processors
$(addprefix results/%QTL/, $(QTL_RAW_FILES)): scripts/%QTL.R utils/QTL-common.R
	$(word 1, $^) --args $(shell echo $$LSB_DJOB_NUMPROC)

# results/pairs/ace_me.tsv etc.
# requires results/ace_e_pairs.tsv etc.
# argument is pair to process, eg. '--args ace me'
results/pairs/%.tsv: scripts/pairs_qvalue.R $(PAIR_RAW_PATHS)
	$(word 1, $^) --args $(wordlist 1, 2, $(subst _, , $(patsubst %.tsv, %, $(notdir $@))))

# results/ace_e_pairs.tsv etc.
# argument is pair to process, eg. '--args ace me'
results/%pairs.tsv: scripts/pairs.R
	$^ --args $(wordlist 1, 2, $(subst _, , $(notdir $@)))

# don't delete the raw files
.SECONDARY: $(QTL_RAW_PATHS) $(PAIR_RAW_PATHS)
