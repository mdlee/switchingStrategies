function [strategyList, paramsOne, paramsTwo] = getStrategyList(modelName)
%GETSTRATEGYLIST Get the list of strategy names associated with a ss_ model
% and the parameter list for the first switch-detection inference, and the
% second strategy use and transition matrix inference
%    [strategyList, paramsOne, paramsTwo] = getStrategyList(modelName)

switch modelName
   case 'ss_TTBTallyWADDGuess'
      strategyList = {'ttb', 'tally', 'wadd', 'guess'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
      
   case 'ss_GuessTTBTallyWADDWADDprobSaturated'
      strategyList = {'guess', 'ttb', 'tally', 'wadd', 'waddprob', 'saturated'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime'};
      
   case 'ss_TTBEQWTTBWADDGuess'
      strategyList = {'ttb', 'eqw-ttb', 'wadd', 'guess'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
      
      
end

paramsOne = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
