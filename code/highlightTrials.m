function xTicks = highlightTrials(dataName, nTrials)
% HIGHLIGHTTRIALS sets the tr[ial tick marks for displaying data sets
%    xTicks = highlightTrials(dataName, nTrials)

switch dataName
   
   case {'NewellShanksAll2003', 'NewellShanksHighCost2003', 'NewellShanksLowCost2003'}
      xTicks = [1 60 nTrials];
      
   otherwise
      xTicks = [1 nTrials];
      
end


