function GVOutputBayesNet(BN, fname)
%GVOutputBayesNet(BN)
%
% Output a Bayes Net in GV format. Modified from GMLOutputBayesNet.
%
% INPUT:
%   BN: A class BayesNet object encoding a network
%   FNAME: filename to output, will have '.graphml' added to the end.
%       optional.

fid = fopen(fname,'wt'); 

fprintf(fid,'digraph {\n');
%fprintf(fid,'\tlabelloc="t";\n');
%fprintf(fid,'\tlabel="%s";\n', BN.title);

for i = 1:length(BN.cols)
        fprintf(fid,'\t%s;\n',BN.cols{i});
end
for i = 1:length(BN.adjmat)
    for j = 1:length(BN.adjmat)
        if (BN.adjmat(i,j))
            %fprintf(fid,'\tedge [weight=%f] %s -> %s;\n', ...
            %        full(BN.weightMatrix(i,j)), BN.cols{i}, BN.cols{j});
            fprintf(fid,'\t%s -> %s;\n', BN.cols{i}, BN.cols{j});
        end
    end
end

fprintf(fid,'}\n')
fclose(fid);

end
