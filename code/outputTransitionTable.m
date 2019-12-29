function outputTransitionTable(dataName, modelName, strategyList, pi)
% OUTPUTTRANSITIONTABLE Print to file a latex table that gives the
%   transition probabilities between strategies
%   outputTransitionTable(dataName, modelName, strategyList, pi)

nStrategies = numel(strategyList);

fid = fopen(sprintf('tables/piTable_%s_%s', dataName, modelName), 'w');
fprintf(fid, '\\begin{table}\n');
fprintf(fid, '\\begin{center}\n');
fprintf(fid, '\\begin{tabular}{%s}\n', ['r' repmat('c', [1, nStrategies])]);
fprintf(fid, '\\toprule\n');
str = '';
for idx = 1:nStrategies
   str = sprintf('%s & %s', str, strategyList{idx});
end
fprintf(fid, sprintf('%s \\\\\\\\ \n', str));
fprintf(fid, '\\hline\n');
for idx1 = 1:nStrategies
   str = strategyList{idx1};
   for idx2 = 1:nStrategies
      if idx1 == idx2
         str = sprintf('%s & --', str);
      else
         str = sprintf('%s & %1.2f', str, pi(idx1, idx2));
      end
   end
   fprintf(fid, sprintf('%s \\\\\\\\ \n', str));
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{center}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
end

