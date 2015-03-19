all: phenotypes.png densities venns qtl_example.png qtl_pca.png datatypes_venn.png

densities: $(patsubst %,phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)
venns: eQTL_venn.png meQTL_venn.png aceQTL_venn.png

%.png %/%.png: %.R
	./$^

multiQTL_%.png eQTL_%.png meQTL_%.png aceQTL_%.png: qtl_%.R
	./$^

%.png: %.R
	./$^

clean:
	rm *.png *.pdf
