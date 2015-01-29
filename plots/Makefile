SHELL = /bin/bash
BSUB = bsub -P cogdec $(BSUB_ARGS)
#BSUB_ARGS := -K -R rusage[sulfur_io=1] -q bhour 
MATLAB = matlab -singleCompThread -nodisplay -nojvm -nosplash 

all: all-ish

all-ish: tracks.R
	./$^

all-bsub: tracks.R
	$(BSUB) -o $^.log ./$^

clean:
	rm *.log

