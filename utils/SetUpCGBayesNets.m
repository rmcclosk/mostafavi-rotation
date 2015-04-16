function SetUpCGBayesNets( )
    cgdir = '/home/unix/rmcclosk/packages/cgbayesnets_7_14_14';
    path(path, cgdir);
    curdir = cd(cgdir);
    bnpathscript;
    tic;
    cd(curdir);
    path('utils', path);
end
