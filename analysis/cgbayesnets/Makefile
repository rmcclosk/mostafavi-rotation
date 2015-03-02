analyses = phenotypes modules
pngs = $(patsubst %,%.png,$(analyses))
gvs = $(patsubst %,%.gv,$(analyses))

all: $(pngs)

.SECONDARY: $(gvs)

%.png: %.gv
	dot -Tpng $^ > $@

%.gv: %.m
	matlab -nojvm -nodisplay -singleCompThread < $^
