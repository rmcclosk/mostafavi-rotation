all: deal.png cgbayesnets.png

deal.png:
	./deal.R

cgbayesnets.png: cgbayesnets.gv
	dot -Tpng $^ > $@

cgbayesnets.gv:
	matlab -singleCompThread -nodesktop -nosplash -nojvm < cgbayesnets.m
	
