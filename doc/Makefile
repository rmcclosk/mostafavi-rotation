all: presentation.pdf

%.pdf: %.tex
	pdflatex -shell-escape $^

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
