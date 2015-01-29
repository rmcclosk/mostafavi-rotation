analyses = deal deal-genes cgbayesnets cgbayesnets-genes
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

clean:
	rm -f *.net *.png *.gv
