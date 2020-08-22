function outputTransitionTableNew(dataName, modelName, strategyList, chains, CIflag, CIbounds)
% OUTPUTTRANSITIONTABLE Print to file a latex table that gives the
%   transition probabilities between strategies
%   outputTransitionTable(dataName, modelName, strategyList, pi)

nStrategies = numel(strategyList);
pi = get_matrix_from_coda(chains, 'pi', @mean);

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
          if CIflag % show CIs
          bounds = prctile(chains.(sprintf('pi_%d_%d', idx1, idx2))(:), CIbounds);
         str = sprintf('%s & %1.2f (%1.2f--%1.2f)', str, pi(idx1, idx2), bounds);
          else
              str = sprintf('%s & %1.2f', str, pi(idx1, idx2));
          end
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

