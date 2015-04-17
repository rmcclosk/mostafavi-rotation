all: results tables plots doc

include plots.mk
include tables.mk
include results.mk
include scripts.mk
include utils.mk
include data.mk

clean:
	rm -f doc/*.dpth
	rm -f doc/*.pdf
	rm -f doc/*.aux
	rm -f doc/*.nav
	rm -f doc/*.log
	rm -f doc/*.out
	rm -f doc/*.snm
	rm -f doc/*.toc
	rm -f doc/*.auxlock
