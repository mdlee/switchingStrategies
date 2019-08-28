function choiceProbability = predictionBrusovansky(valuesA, valuesB, cuesA, cuesB, validity, strategy)

% function choiceProbability = predictionBrusovansky(valuesA, valuesB, cuesA, cuesB, validity, strategy)
% implemented strategies are
%   ttb: take-the-best on cue version of values
%   tally: tally sum of number of cues
%   wadd: normative weighted additive, sum of log odds of validities
%   waddS: non-normative weighted additive, sum of validities
%   eqw-ttb: choose by unweighted sum of values, resort to TTB if they are
%   equal (BrusovanskyEtAl2018)

%% Pre-preocess
nCues = length(valuesA);
[~, ~, rank] = unique(validity);

%% Predictions
% Weights on cues
switch strategy
   case 'ttb'
      w = 2.^(rank-1);
      totalA = round(dot(cuesA, w), 10); % rounding handles numerical precision issues
      totalB = round(dot(cuesB, w), 10);
      % predictions
      if totalA > totalB
         choiceProbability = 1;
      elseif totalA < totalB
         choiceProbability = 0;
      else % tie
         choiceProbability = 0.5;
      end
      
   case 'eqw-ttb'
      
      totalA = round(dot(valuesA, ones(1, nCues)), 10); % rounding handles numerical precision issues
      totalB = round(dot(valuesB, ones(1, nCues)), 10);
      % predictions
      if totalA > totalB
         choiceProbability = 1;
      elseif totalA < totalB
         choiceProbability = 0;
      else % tie, so ttb
         w = 2.^(rank-1);
         totalA = round(dot(cuesA, w), 10); % rounding handles numerical precision issues
         totalB = round(dot(cuesB, w), 10);
         % predictions
         if totalA > totalB
            choiceProbability = 1;
         elseif totalA < totalB
            choiceProbability = 0;
         else % tie
            choiceProbability = 0.5;
         end
      end
      
   case 'wadd'
      totalA = round(dot(valuesA, validity), 10); % rounding handles numerical precision issues
      totalB = round(dot(valuesB, validity), 10);
      % predictions
      if totalA > totalB
         choiceProbability = 1;
      elseif totalA < totalB
         choiceProbability = 0;
      else % tie
         choiceProbability = 0.5;
      end
        
   case 'guess'
      choiceProbability = 0.5;
      
end




