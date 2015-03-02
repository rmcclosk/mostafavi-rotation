all: compare-modules.png

compare-modules.png: compare-modules.gv
	dot -Tpng $^ > $@

compare-modules.gv: compare_graphs.py deal/modules.gv cgbayesnets/modules.gv
	./$^ > $@
