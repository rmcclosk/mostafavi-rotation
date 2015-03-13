all: phenotypes.png modules.png modules.gv qtl.png

%.png: %.R
	./$^

modules.gv: net2gv.py modules.net
	./$(word 1,$^) < $(word 2,$^) > $@
