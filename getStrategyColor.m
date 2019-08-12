function colorVec = getStrategyColor(strategyName, pantone)
%GETSTRATEGYCOLOR Get the pantone color of a strategy
%    colorVec = getStrategyColor(strategyName, pantone)
switch strategyName
   case 'ttb', colorVec = pantone.Custard;
   case 'tally', colorVec = pantone.Aquamarine;
   case 'wadd', colorVec = pantone.DuskBlue;
   case 'guess', colorVec = pantone.Sandstone;
   case 'saturated', colorVec = pantone.Tangerine;
   case 'waddprob', colorVec = pantone.ClassicBlue;
   case 'eqw-ttb', colorVec = pantone.Scuba;
end

