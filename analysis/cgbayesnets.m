% set up CGBayesNets
cgdir = '/home/unix/rmcclosk/packages/cgbayesnets_7_14_14';
path(path, cgdir);
curdir = cd(cgdir);
bnpathscript;
tic;
cd(curdir);

fname = tempname;
vars = {'tangles_sqrt', 'amyloid_sqrt', 'globcog_random_slope', 'pathoAD', 'pmAD'};

query = ['SELECT ', strjoin(vars, ', '), ' FROM patient WHERE ', ...
         strjoin(vars, ' IS NOT NULL AND '), ' IS NOT NULL'];
cmd = ['sqlite3 -csv -header ../data/db-pheno.sqlite "', query, '" > ', fname];
system(cmd);

% common parameter values:
%       priorPrecision.nu; % prior sample size for prior variance estimate
%       priorPrecision.sigma2; % prior variance estimate
%       priorPrecision.alpha; % prior sample size for discrete nodes
%       priorPrecision.maxParents; % hard-limit on the number of parents
priorPrecision.nu = 1;
priorPrecision.sigma2 = 1;
priorPrecision.alpha = 10; 
priorPrecision.maxParents = 3;

[data, cols] = RCSVLoad(fname, false, ',');
FullBNet = FullBNLearn(data, cols, 'pmAD', 0, 'pmAD', priorPrecision);
GVOutputBayesNet(FullBNet, 'cgbayesnets.gv');

% gives the same result
%FullBNet = FullBNLearn(data, cols, 'pathoAD', 0, 'pathoAD', priorPrecision);
%GVOutputBayesNet(FullBNet, 'pathoAD.gv');

delete(fname);
