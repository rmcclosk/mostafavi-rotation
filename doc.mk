doc: doc/beamercolorthemesolarized.sty doc/presentation.pdf

doc/beamercolorthemesolarized.sty:
	wget -O $@ https://raw.githubusercontent.com/jrnold/beamercolorthemesolarized/master/$(notdir $@) --no-check-certificate

doc/%.pdf: doc/%.tex
	pdflatex -shell-escape $(word 1,$^)
