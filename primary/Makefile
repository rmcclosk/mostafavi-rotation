CHRS = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22

all: raw best

raw: $(patsubst %,eQTL/chr%.tsv,$(CHRS)) $(patsubst %,meQTL/chr%.tsv,$(CHRS)) $(patsubst %,aceQTL/chr%.tsv,$(CHRS))

best: eQTL/best.tsv meQTL/best.tsv aceQTL/best.tsv

eQTL/chr%.tsv: eQTL.R
	./$^

meQTL/chr%.tsv: meQTL.R
	./$^

aceQTL/chr%.tsv: aceQTL.R
	./$^

%/best.tsv:
	./qvalue.R

multi_qtl.tsv: multi_qtl.R
	./$^
