Rotation with the Mostafavi lab
===============================

This is the repository for Rosemary McCloskey's Spring 2015 rotation project
with Sara Mostafavi.

This README is about the code side of the project: how the files and folders
are organized, and how to rerun all the analyses and produce all the figures
and tables. For the science side, I have written a summary which can be found
[here](https://github.com/rmcclosk/mostafavi-rotation/wiki/Summary). The
summary should be read first. Note that the repo, and the wiki, are private.

I have tried to document everything as thoroughly as possible, but please
contact me at <rmcclosk.math@gmail.com> if you have any questions.

Set up
------

If you are on the Broad server, you will need to type these commands into the
shell.

    use R-3.1
    use Python-3.4
    use Tex-Latex
    use Graphviz
    use ImageMagick

Running everything
------------------

The entire project is run using a Makefile. It's called GNUmakefile because I
make heavy use of pattern rules, which are a GNU make extension. The main
GNUmakefile sources several other makefiles, each with the suffix `.mk`, in the
root directory. These are generally responsible for the files in the directory
of the same name.

To see all the commands which were used in the project, type `make -nB` into
the terminal. Some of these commands (the ones which create a symlink) won't
work if you try to run them again, because the symlink is already there. Also,
a couple of the data files were sent to me in an email, so these cannot be
remade.

All the code expects to be run or sourced from the project's root directory
(where this README is). Most of the scripts won't work if you try to run them
from the scripts directory or anywhere else. 

In any case, the code should generally not be run directly; instead you should
use `make somedir/somefile`, where `somedir/somefile` is the file you want to
produce (probably something in results, plots, or tables). You can use `make
-B` to force the file to be remade, even if make thinks it's up to date.

The Rdata files in the cache folder are generally named out of a hash of the
script's input data, so that if the data changes, you shouldn't need to
manually delete the Rdata. However, if the script is altered significantly
enough that the Rdata file needs to change, it will have to be manually
deleted.

If you have just cloned this repository, you will at least need to do 
`make data` to get all the data files in place.

Notes
-----

There are some utility functions in [utils/load_data.R]
(https://github.com/rmcclosk/mostafavi-rotation/blob/master/utils/load_data.R)
which load all the data in the project and format it into either data.tables,
or matrices with patients as rows and features as columns. Details about these
functions are in the comments in the file, and there are numerous examples of
their usage in the scripts folder. In general, they are the preferred method of
accessing the raw data, rather than loading the files in the data directory.

Most of the scripts make use of the data.table R package, which can manipulate
large data sets orders of magnitude faster than data.frame in base R. All of
the data.frame operations also work on data.tables.

Folder structure
----------------

Each folder has its own README listing all the files contained in it.

__data__ contains all the raw data.

__scripts__ contains all the top-level scripts used to generate results and
plots.

__utils__ contains library functions and utilities that are called by scripts.

__results__ contains unprocessed results (mostly in TSV format), such as lists
of all QTLs.

__plots__ and __tables__ contain figures and summary tables.

__cache__ is used to store `.RData` files so that scripts can be run more
quickly subsequent times. 

__doc__ contains presentation material.

Gotchas
-------

There are a few things I would like to have done differently in this project,
and that might trip up somebody trying to take over. These are documented here.

Firstly, a lot of the analyses remove 10 principal components from the gene
expression, acetylation, and methylation data. This is intended to remove broad
effects and get the data down to the level where genetic factors have an effect.
However, the number 10 is arbitrary and was chosen based on visual inspection
of [this plot]
(https://github.com/rmcclosk/mostafavi-rotation/blob/master/plots/qtl_pca.png).
Unfortunately, instead of making a global script containing the number 10, I
put it at the top of basically every analysis file. If you come up with a more
rigorous way of deciding how many PCs to remove, pretty much every script will
need to be modified.
