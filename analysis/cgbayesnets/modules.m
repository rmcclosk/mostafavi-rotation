% run CGBayesNets on gene mdata plus phenotypes

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

searchParameter.backtracking = true;
searchParameter.nophenotype = true;

% read module means
fid = fopen('../../data/module_means_filtered_byphenotype.txt');
header = strsplit(fgetl(fid), '\t');
mcols = header(2:end);

fmt = ['%s' repmat('%f', 1, length(header)-1)];
mdata = textscan(fid, fmt);
fclose(fid);
mpatients = mdata{:,1};
mpatients = regexprep(mpatients, ':.*', '');
mdata = cell2mat(mdata(:,2:end));

% read phenotypes 
fid = fopen('../../data/pheno_cov_n2963_092014_forPLINK.csv');
header = strsplit(fgetl(fid), ',');
fmt = ['%s' '%s' '%s' repmat('%f', 1, length(header)-3)];

pcols = {'tangles_sqrt', 'amyloid_sqrt', 'globcog_random_slope', 'pathoAD', 'pmAD'};
col_idx = [];
for i = 1:length(pcols)
    col_idx = [col_idx find(strcmp(header, pcols{i}))]; 
end

pdata = textscan(fid, fmt, 'Delimiter', ',', 'TreatAsEmpty', {'NA'});
fclose(fid);

ppatients = pdata{:,3};
pdata = cell2mat(pdata(:,col_idx));
pdata(pdata == -9) = NaN;

% match patients from two datasets
patients = intersect(mpatients, ppatients);
mrows = [];
prows = [];
for i = 1:length(patients)
    mrows = [mrows find(strcmp(mpatients, patients{i}))];
    prows = [prows find(strcmp(ppatients, patients{i}))];
end
mdata = mdata(mrows,:);
pdata = pdata(prows,:);

data = [mdata pdata];
cols = [mcols pcols];
data = data(all(isfinite(data), 2),:);
disc = IsDiscrete(data);

% build the network
FullBNet = FullBNLearn(data, cols, 'pmad', 0, 'pmad', priorPrecision, disc, false, searchParameter);
GVOutputBayesNet(FullBNet, 'modules.gv');
