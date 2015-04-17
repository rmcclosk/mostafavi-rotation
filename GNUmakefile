# some global variables which are used in multiple places

# utility scripts for running CGBayesNets analyses
CGB_UTILS = utils/GVOutputBayesNet.m utils/RCSVLoad.m utils/SetUpCGBayesNets.m

# directories where QTL data is stored
QTL_FOLDERS = results/eQTL results/meQTL results/aceQTL

# names of files where QTL data is stored, without extensions: PC0, PC1, etc.
QTL_FILE_NAMES = $(addprefix PC, 0.nocov 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

# names of files where raw QTL data is stored: PC0.tsv, PC1.tsv, etc.
QTL_RAW_FILES = $(addsuffix .tsv, $(QTL_FILE_NAMES))

# full paths to files where raw QTL data is stored: eQTL/PC0.tsv etc.
QTL_RAW_PATHS = $(foreach DIR, $(QTL_FOLDERS), $(addprefix $(DIR)/, $(QTL_RAW_files)))

# names of files where q-value processed QTL data is stored: PC0.best.tsv, PC1.best.tsv, etc.
QTL_BEST_FILES = $(addsuffix .best.tsv, $(QTL_FILE_NAMES))

# full paths to files where q-value processed QTL data is stored: meQTL/PC0.best.tsv etc.
QTL_BEST_PATHS = $(foreach DIR, $(QTL_FOLDERS), $(addprefix $(DIR)/, $(QTL_BEST_FILES)))

# files where raw pairwise correlation data is stored
PAIR_RAW_PATHS = $(addprefix results/, ace_e_pairs.tsv ace_me_pairs.tsv e_me_pairs.tsv)

# files where q-value processed pair correlations are stored: results/pairs/ace_e.tsv etc.
PAIR_BEST_PATHS = $(addsuffix .tsv, $(addprefix results/pairs/, ace_e ace_me e_ace e_me me_ace me_e))

all: results tables plots doc

include doc.mk
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
