# This is the Makefile for everything in the results directory, which contains
# 'raw' results (ie. tsv files).
# TODO: this isn't working yet!!

QTL_FOLDERS = $(patsubst %,results/%QTL,e ace me)
QTL_BASE = $(patsubst %,PC%,0.nocov 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
QTL_RAW = $(foreach DIR,$(QTL_FOLDERS),$(foreach BASE,$(QTL_BASE),$(DIR)/$(BASE).tsv))
QTL_BEST = $(foreach DIR,$(QTL_FOLDERS),$(foreach BASE,$(QTL_BASE),$(DIR)/$(BASE).best.tsv))

PAIRS_BEST = $(addsuffix .tsv, $(addprefix results/pairs/, ace_e ace_me e_ace e_me me_ace me_e))

results: $(addprefix results/,multi_qtl_data.tsv) $(PAIRS_BEST)

results/pairs/%.tsv: scripts/pairs_qvalue.R 
	$^ --args $(wordlist 1, 2, $(subst _, , $(patsubst %.tsv, %, $(notdir $@))))

results/%pairs.tsv: scripts/pairs.R
	$^ --args $(wordlist 1, 2, $(subst _, , $(notdir $@)))

results/multi_qtl_data.tsv: scripts/multi_qtl_data.R results/multi_qtl.tsv
	$(word 1, $^)

results/multi_qtl.tsv: scripts/multi_qtl.R $(QTL_BEST)
	$(word 1, $^)
	
## eQTL/PC1.best.tsv et al.
#$(foreach BASE,$(QTL_BASE),results/%QTL/$(BASE).best.tsv): scripts/qvalue.R $(foreach BASE,$(QTL_BASE),results/%QTL/$(BASE).tsv)
#	$(word 1, $^) --args $(dir $@)
#
## eQTL/PC1.tsv et al.
#$(foreach BASE,$(QTL_BASE),results/%QTL/$(BASE).tsv): scripts/%QTL.R utils/QTL-common.R
#	$(word 1, $^) --args $(shell echo $$LSB_DJOB_NUMPROC)
#
## don't delete any intermediate files
#.SECONDARY: $(QTL_RAW)
