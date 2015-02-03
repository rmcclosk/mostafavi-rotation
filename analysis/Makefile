analyses = deal deal-genes cgbayesnets cgbayesnets-genes compare-genes
pngs = $(patsubst %,%.png,$(analyses))
gvs = $(patsubst %,%.gv,$(analyses))

all: $(pngs)

.SECONDARY: $(gvs)

deal.png: deal.R
	./$^

%.png: %.gv
	dot -Tpng $^ > $@

cg%.gv: cg%.m
	matlab -singleCompThread -nodesktop -nosplash -nojvm < $^

deal%.gv: deal%.net
	./net2gv.py < $^ > $@

deal%.net: deal%.R
	./$^

compare-genes.gv: deal-genes.gv cgbayesnets-genes.gv
	./compare_graphs.py $^ > $@

clean:
	rm -f *.net *.png *.gv
