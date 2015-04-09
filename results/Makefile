CHRS = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
QTL_FILES = $(patsubst %,QTL/chr%.tsv,$(CHRS))

all: multi_qtl_data.tsv

multi_qtl_data.tsv: multi_qtl_data.R multi_qtl.tsv
	./$(word 1, $^)

multi_qtl.tsv: multi_qtl.R eQTL/best.tsv meQTL/best.tsv aceQTL/best.tsv
	./$(word 1, $^)

%QTL/best.tsv: qvalue.R $(addprefix %,$(QTL_FILES))
	./$(word 1, $^) --args $(dir $@)
	
qtls: $(addprefix e,$(QTL_FILES)) $(addprefix me,$(QTL_FILES)) $(addprefix ace,$(QTL_FILES))

$(addprefix %,$(QTL_FILES)): %QTL.R QTL-common.R
	./$(word 1, $^)
