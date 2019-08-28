function outputCombinedTransitionTable(dataName, modelName, strategyList, storePi)
%OUTPUTCOMBINEDTRANSITIONTABLE Print to file a latex table that gives the
%transition probabilities between strategies for a set of related models
%currently supports only 2 or 3 datasets with bold then bold italic
%highlighting of successive sets
%   outputCombinedTransitionTable(dataName, modelName, strategyList, storePi)


nStrategies = numel(strategyList);
nDatasets = numel(storePi);

fid = fopen(sprintf('tables/piCombinedTable_%s_%s', dataName, modelName), 'w');
switch nDatasets
   case 2, fprintf(fid, '\\begin{table}\n');
   case 3, fprintf(fid, '\\begin{table*}\n');
end
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
   fprintf(fid, '%s', strategyList{idx1});
   for idx2 = 1:nStrategies
      if idx1 == idx2
         fprintf(fid, '& --');
      else
         
         switch nDatasets
            case 2, fprintf(fid, '& %1.2f \\textbf{%1.2f} ', storePi{1}(idx1, idx2), storePi{2}(idx1, idx2));
            case 3, fprintf(fid, '& \\textit{%1.2f} %1.2f \\textbf{%1.2f} ', storePi{1}(idx1, idx2), storePi{2}(idx1, idx2), storePi{3}(idx1, idx2));
         end
      end
   end
   fprintf(fid, '\\\\ \n');
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{center}\n');
switch nDatasets
   case 2, fprintf(fid, '\\end{table}\n');
   case 3, fprintf(fid, '\\end{table*}\n');
end
fclose(fid);
end

