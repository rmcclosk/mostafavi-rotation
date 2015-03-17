analyses = phenotypes modules qtl
pngs = $(patsubst %,%.png,$(analyses))
gvs = $(patsubst %,%.gv,$(analyses))

all: $(pngs)

.SECONDARY: $(gvs)

# needs the JVM to print graphics arrrrgh
qtl.png: qtl.m
	matlab -nodisplay -singleCompThread < $^

%.png: %.gv
	dot -Tpng $^ > $@

%.gv: %.m
	matlab -nojvm -nodisplay -singleCompThread < $^
