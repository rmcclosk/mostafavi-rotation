FIGURES = $(addprefix doc/figures/, datatypes_venn.pdf \
									qtl_example.pdf \
									qtl_overlap.pdf \
									qtl_pca.pdf \
									qtl_venn.pdf)

doc: doc/presentation.pdf

doc/figures/%.pdf: plots/%.pdf
	ln -s $(shell pwd)/$^ $@

doc/%.pdf: doc/%.tex
	pdflatex -output-directory doc -shell-escape $(word 1,$^)
