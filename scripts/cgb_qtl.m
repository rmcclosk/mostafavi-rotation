path('utils', path);
SetUpCGBayesNets;

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

% read the data
fid = fopen(fullfile('results', 'multi_qtl_data.tsv'));
header = strsplit(fgetl(fid), '\t');
fmt = [repmat('%s', 1, 5), repmat('%f', 1, 4)];
data = textscan(fid, fmt, 'Delimiter', '\t', 'TreatAsEmpty', {'NA'});
fclose(fid);

% find the numeric columns
g_idx = find(ismember(header, 'g'));
e_idx = find(ismember(header, 'e'));
a_idx = find(ismember(header, 'ace'));
m_idx = find(ismember(header, 'me'));
cols = [g_idx e_idx a_idx m_idx];

% order by SNP
snp_idx = find(ismember(header, 'snp'));
[~, order] = sort(data{snp_idx});
numdata = cell2mat(data(cols));
numdata = numdata(order,:);

% find the boundaries of data for each snp
snps = data{snp_idx};
snps = snps(order);
[~,starts,~] = unique(snps);
[nqtl,~] = size(starts);

disc = IsDiscrete(numdata);

% get the model string for each network
% as far as I can tell CGBayesNets has no blacklist capabilities
cols = header(cols); % use column names instead of numbers
topos = [];
[nrow,~] = size(numdata);
for i = 1:nqtl
    if (i < nqtl)
        bnData = numdata(starts(i):(starts(i+1)-1),:);
    else
        bnData = numdata(starts(i):nrow,:);
    end
    net = FullBNLearn(bnData, cols, 'foo', 0, 'foo', priorPrecision, disc, false, searchParameter);
    str = '';
    for i = 1:4
        str = strcat(str, '[', cols(i));
        first = true;
        for j = 1:4
            if net.adjmat(j, i) == 1
                if first
                    str = strcat(str, '|', cols(j));
                    first = false;
                else
                    str = strcat(str, ':', cols(j));
                end
            end
        end
        str = strcat(str, ']');
    end 
    topos = [topos; str];
end

topos = sort(topos);
[ntopos,~] = size(topos);
[topos, idx] = unique(topos);
counts = diff([idx; ntopos+1]);
[counts, order] = sort(counts);

topos = topos(fliplr(order));
counts = counts(fliplr(order));

topos = topos(order);
counts = counts(order);

[ntopos,~] = size(topos);

set(0,'defaultfigurepaperunits','inches');
set(0,'defaultfigurepaperorientation','portrait');
set(0,'defaultfigurepapersize',[5 8]);
set(0,'defaultfigurepaperposition',[.25 .25 [5 8]-0.5]);

figure
barh(counts);
ylim([0 ntopos+1]);
set(gca, 'YTickMode', 'manual', 'YTick', 1:ntopos, 'YTickLabel', topos);
print(fullfile('plots', 'cgb_qtl'), '-dpng', '-r300');
print(fullfile('plots', 'cgb_qtl'), '-dpdf');
