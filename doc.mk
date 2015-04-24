FIGURES = $(addprefix doc/figures/, datatypes_venn.pdf \
									qtl_example.pdf \
									qtl_overlap.pdf \
									qtl_pca.pdf \
									qtl_venn.pdf)

doc: doc/presentation.pdf

doc/presentation.pdf: doc/beamercolorthemesolarized.sty $(FIGURES)

doc/beamercolorthemesolarized.sty:
	wget -O $@ https://raw.githubusercontent.com/jrnold/beamercolorthemesolarized/master/$(notdir $@) --no-check-certificate

doc/figures/%.pdf: plots/%.pdf
	ln -s $(shell pwd)/$^ $@

doc/%.pdf: doc/%.tex
	pdflatex -output-directory doc -shell-escape $(word 1,$^)
