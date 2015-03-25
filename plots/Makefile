all: phenotypes.png densities qtl_venn.png qtl_example.png qtl_pca.png datatypes_venn.png

densities: $(patsubst %,phenotypes/%.png,amyloid_sqrt globcog_random_slope tangles_sqrt)

%.png %/%.png: %.R
	./$^

%.png: %.R
	./$^

clean:
	rm *.png *.pdf *.tex
