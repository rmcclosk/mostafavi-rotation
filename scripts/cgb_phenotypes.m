% Analyse phenotype relationships with CGBayesNets.

path('utils', path);
SetUpCGBayesNets;

[data, cols] = RCSVLoad(fullfile('data', 'patients.tsv'), true, '\t', false, [2]);
vars = {'tangles_sqrt', 'amyloid_sqrt', 'globcog_random_slope', 'pathoAD', 'pmAD'};

col_idx = [];
for i = 1:length(vars)
    col_idx = [col_idx find(strcmp(cols, vars{i}))]; 
end

cols = cols(col_idx);
data = data(:,col_idx-2);
data = data(all(isfinite(data), 2),:);

% common parameter values:
%       priorPrecision.nu; % prior sample size for prior variance estimate
%       priorPrecision.sigma2; % prior variance estimate
%       priorPrecision.alpha; % prior sample size for discrete nodes
%       priorPrecision.maxParents; % hard-limit on the number of parents
priorPrecision.nu = 1;
priorPrecision.sigma2 = 1;
priorPrecision.alpha = 10;
priorPrecision.maxParents = 3;

searchParameter.backtracking = true;
searchParameter.nophenotype = true;

disc = IsDiscrete(data);

FullBNet = FullBNLearn(data, vars, 'pmAD', 0, 'pmAD', priorPrecision, disc, false, searchParameter);
GVOutputBayesNet(FullBNet, fullfile('results', 'cgb_phenotypes.gv'));