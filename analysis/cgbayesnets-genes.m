SetUpCGBayesNets;

% common parameter values:
%       priorPrecision.nu; % prior sample size for prior variance estimate
%       priorPrecision.sigma2; % prior variance estimate
%       priorPrecision.alpha; % prior sample size for discrete nodes
%       priorPrecision.maxParents; % hard-limit on the number of parents
priorPrecision.nu = 1;
priorPrecision.sigma2 = 1;
priorPrecision.alpha = 10; 
priorPrecision.maxParents = 10;

[data, cols] = RCSVLoad('modules-genes.tsv', true);
FullBNet = FullBNLearn(data, cols, 'pmad', 0, 'pmad', priorPrecision);
GVOutputBayesNet(FullBNet, 'cgbayesnets-genes.gv');
