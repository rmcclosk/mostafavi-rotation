Cache
=====

This is a folder where programs can save the results of long computation in
.Rdata files, so that subsequent runs are faster. They are typically named by a
hash of the input file name, so they won't be reused if the data changes. But
they _will_ be reused if the script changes and not the data, so if you edit
any of the scripts that use these files, be sure to delete them manually before
rerunning the script.
