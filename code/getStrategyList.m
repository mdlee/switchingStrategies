function [strategyList, paramsOne, paramsTwo, paramsThree] = getStrategyList(modelName)
  % GETSTRATEGYLIST Get the list of strategy names associated with a ss_ model
  %   or ssLM_ model for the hierarchical models and its latent mixture extension
  %   also gets the parameter lists for the first switch-detection inference and the
  %   second strategy use and transition matrix inference (for the hierarchical model)
  %   or the first latent mixture inference, second switch-detection inference and the
  %   third strategy use and transition matrix inference (for the latent mixture extenion)

switch modelName
   
   case 'ss_TTBTallyWADDGuess'
      strategyList = {'ttb', 'tally', 'wadd', 'guess'};
      paramsOne = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
      
   case 'ss_GuessTTBTallyWADDWADDprobSaturated'
      strategyList = {'guess', 'ttb', 'tally', 'wadd', 'waddprob', 'saturated'};
      paramsOne = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime'};
      
   case 'ss_TTBEQWTTBWADDGuess'
      strategyList = {'ttb', 'eqw-ttb', 'wadd', 'guess'};
      paramsOne = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsTwo = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
      
   case 'ssLM_TTBTallyWADDGuess'
      strategyList = {'ttb', 'tally', 'wadd', 'guess'};
      paramsOne = {'x', 'phi'};
      paramsTwo = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsThree = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
      
   case 'ssLM_GuessTTBTallyWADDWADDprobSaturated'
      strategyList = {'guess', 'ttb', 'tally', 'wadd', 'waddprob', 'saturated'};
      paramsOne = {'x', 'phi'};
      paramsTwo = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsThree = {'epsilon', 'z', 'pi', 'piPrime'};
      
   case 'ssLM_TTBEQWTTBWADDGuess'
      strategyList = {'ttb', 'eqw-ttb', 'wadd', 'guess'};
      paramsOne = {'x', 'phi'};
      paramsTwo = {'tau', 'gamma', 'muGamma', 'sigmaGamma'};
      paramsThree = {'epsilon', 'z', 'pi', 'piPrime', 'choice'};
           
end


