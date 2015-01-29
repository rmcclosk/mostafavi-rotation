% set up CGBayesNets
cgdir = '/home/unix/rmcclosk/packages/cgbayesnets_7_14_14';
path(path, cgdir);
curdir = cd(cgdir);
bnpathscript;
tic;
cd(curdir);

% common parameter values:
%       priorPrecision.nu; % prior sample size for prior variance estimate
%       priorPrecision.sigma2; % prior variance estimate
%       priorPrecision.alpha; % prior sample size for discrete nodes
%       priorPrecision.maxParents; % hard-limit on the number of parents
priorPrecision.nu = 1;
priorPrecision.sigma2 = 1;
priorPrecision.alpha = 10; 
priorPrecision.maxParents = 3;

[data, cols] = RCSVLoad('modules-genes.tsv', true);
FullBNet = FullBNLearn(data, cols, 'pmad', 0, 'pmad', priorPrecision);
GVOutputBayesNet(FullBNet, 'cgbayesnets-genes.gv');

% gives the same result
%FullBNet = FullBNLearn(data, cols, 'pathoAD', 0, 'pathoAD', priorPrecision);
%GVOutputBayesNet(FullBNet, 'pathoAD.gv');
