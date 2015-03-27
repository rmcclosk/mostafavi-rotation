all: beamercolorthemesolarized.sty presentation.pdf

beamercolorthemesolarized.sty:
	wget https://raw.githubusercontent.com/jrnold/beamercolorthemesolarized/master/$@ --no-check-certificate

%.pdf: %.tex
	pdflatex -shell-escape $(word 1,$^)

clean:
	rm -f *.dpth
	rm -f *.pdf
	rm -f *.aux
	rm -f *.nav
	rm -f *.log
	rm -f *.out
	rm -f *.snm
	rm -f *.toc
	rm -f *.auxlock
