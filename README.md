Rotation with the Mostafavi lab
===============================

This is the repository for Rosemary McCloskey's Spring 2015 rotation project
with Sara Mostafavi.

Set up
------

If you are on the Broad server, you will need to type these commands into the
shell.

    use R-3.1
    use Python-3.4
    use Matlab
    use Tex-Latex
    use Graphviz

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
