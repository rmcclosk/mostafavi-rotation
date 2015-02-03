SetUpCGBayesNets;

con = database('cogdec','rmcclosk','', 'Vendor','PostgreSQL');
vars = {'tangles_sqrt', 'amyloid_sqrt', 'globcog_random_slope', 'pathoAD', 'pmAD'};

query = ['SELECT ', strjoin(vars, ', '), ' FROM patient WHERE ', ...
         strjoin(vars, ' IS NOT NULL AND '), ' IS NOT NULL'];
curs = exec(con, query);
curs = fetch(curs);
[nrow, ncol] = size(curs.Data);
for i=1:nrow
    for j=1:ncol
        data(i,j) = cast(cell2mat(curs.Data(i, j)), 'double');
    end;
end;

% common parameter values:
%       priorPrecision.nu; % prior sample size for prior variance estimate
%       priorPrecision.sigma2; % prior variance estimate
%       priorPrecision.alpha; % prior sample size for discrete nodes
%       priorPrecision.maxParents; % hard-limit on the number of parents
priorPrecision.nu = 1;
priorPrecision.sigma2 = 1;
priorPrecision.alpha = 10; 
priorPrecision.maxParents = 3;

FullBNet = FullBNLearn(data, vars, 'pmAD', 0, 'pmAD', priorPrecision);
GVOutputBayesNet(FullBNet, 'cgbayesnets.gv');
