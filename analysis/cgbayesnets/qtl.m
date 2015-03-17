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

% load the data
[data, cols, ~, keep_cols] = RCSVLoad('../../primary/multi_qtl_data.tsv', ...
                                      true, ...
                                      '\t', ...
                                      false, ...
                                      ['feature.me' 'feature.ace' 'feature.e']);
cols = cols(keep_cols);

% order by SNP
snp_idx = find(ismember(cols, 'snp'));
[~, order] = sort(data(:, snp_idx));
data = data(order,:);

% find the boundaries of data for each snp
[~,starts,~] = unique(data(:, snp_idx));
[nqtl,~] = size(starts);

g_idx = find(ismember(cols, 'g'));
e_idx = find(ismember(cols, 'e'));
a_idx = find(ismember(cols, 'ace'));
m_idx = find(ismember(cols, 'me'));

cols = cols([g_idx e_idx a_idx m_idx]);
data = data(:,[g_idx e_idx a_idx m_idx]);
disc = IsDiscrete(data);

% get the model string for each network
% as far as I can tell CGBayesNets has no blacklist capabilities
topos = [];
[nrow,~] = size(data);
for i = 1:nqtl
    if (i < nqtl)
        bnData = data(starts(i):(starts(i+1)-1),:);
    else
        bnData = data(starts(i):nrow,:);
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
topos = topos(order);

[ntopos,~] = size(topos);

set(0,'defaultfigurepaperunits','inches');
set(0,'defaultfigurepaperorientation','portrait');
set(0,'defaultfigurepapersize',[5 8]);
set(0,'defaultfigurepaperposition',[.25 .25 [5 8]-0.5]);

figure
barh(counts);
ylim([0 ntopos+1]);
set(gca, 'YTickMode', 'manual', 'YTick', 1:ntopos, 'YTickLabel', topos);
print('qtl', '-dpng', '-r300');
print('qtl', '-dpdf');
