# Switching Strategies

MATLAB and JAGS code for inferring switches in decision-making strategies in multi-attribute choice tasks. All of the analyses used [JAGS v4.3.0](http://mcmc-jags.sourceforge.net/) and the [trinity](https://github.com/joachimvandekerckhove/trinity) package. 

## Code

The two main code files are the MATLAB scripts `strategySwitchingOneGroup.m` for the hierarchical model and `strategySwitchingTwoGroups.m` for the latent mixture extension. Both scripts have the same set of user inputs in the first code block, controlling which data set is to be analyzed, and which plotting table analyses are to be done. There need to be subfolders called `figures` and `tables` for these outputs to be produced. The scripts produce additional output in the command window, including posterior estimates and Bayes factors.

```
% analysis list has data name, model name, subject list, number of rows and columns for plotting
analysisList = {...
   {'WalshGluck2016', 'ss_TTBTallyWADDGuess', 1:38, [4, 2]}; ...
   };

drawIndividuals = false;     % set to true to draw all partipant-level plots
drawChange = false;          % set to true to draw just participants inferred to change strategies
drawOverall = false;         % set of true to draw overall plot of all participants
printTable = false;          % set to true to generate LATEX transition probability table to table subfolder
printCombinedTable = false;  % set of true to generate LATEX transition table for Brusovansky conditions to table subfolder
doPrint = true;              % set to true to print eps and png figures to figures subfolder  
 
nMaxSwitches = 5;            % maximum number of strategy switches
posteriorMassRatio = 1/2;    % consider posterior masses for changepoints that are at least this likely compared to the mode
maxPosteriors = 5;           % up to this many total possible changepoint possibilities in the posterior

```

These scripts call on the following functions, which need to be updated for new data sets. The existing five data sets and their special cases (specific conditions within the general data sets) provide worked examples.

```
function d = loadStrategySwitchData(dataName)
  % LOADSTRATEGYSWITCHDATA d = loadStrategySwitchData(dataName)
  %   load a data set for strategy switch analysis
```

```
function xTicks = highlightTrials(dataName, nTrials)
  % HIGHLIGHTTRIALS sets the tr[ial tick marks for displaying data sets
  %    xTicks = highlightTrials(dataName, nTrials)
```

```
function [strategyList, paramsOne, paramsTwo, paramsThree] = getStrategyList(modelName)
  % GETSTRATEGYLIST Get the list of strategy names associated with a ss_ model
  %   or ssLM_ model for the hierarchical models and its latent mixture extension
  %   also gets the parameter lists for the first switch-detection inference and the
  %   second strategy use and transition matrix inference (for the hierarchical model)
  %   or the first latent mixture inference, second switch-detection inference and the
  %   third strategy use and transition matrix inference (for the latent mixture extenion)
```

Finally, the scripts use the following external data sets or functions, which should not need to be modified.

```
function [keepChains, bestRhat] = findKeepChains(x, minChains, desiredRhat)
% FINDKEEPCHAINS Find the subset of chains, with at least minChains, that
%   minimizes rHat, from a matrix x with nSamples by nChains
%   the largest number of chains that gets Rhat below desired Rhat is returned
%   requires the gelmanrubin function from trinity
```

```
function outputTransitionTable(dataName, modelName, strategyList, pi)
% OUTPUTTRANSITIONTABLE Print to file a latex table that gives the
%   transition probabilities between strategies
%   outputTransitionTable(dataName, modelName, strategyList, pi)
```

```
function outputCombinedTransitionTable(dataName, modelName, strategyList, storePi)
% OUTPUTCOMBINEDTRANSITIONTABLE Print to file a latex table that gives the
%  transition probabilities between strategies for a set of related models
%  currently supports only 2 or 3 datasets with bold then bold italic
%  highlighting of successive sets
```

```function colorVec = getStrategyColor(strategyName, pantone)
function colorVec = getStrategyColor(strategyName, pantone)
% GETSTRATEGYCOLOR Get the pantone color of a strategy
```

The color palette `pantoneColors.mat`.

## JAGS Scripts

There are two sets of JAGS scripts: one set for the hierarchical model with one group (prefix `ss_`), and another for the latent mixture extension with two groups (prefix `ssLM_`). The hierarchical case has two scripts (suffixes `_A` and `_B`) for inferring switch points, then inferring strategy use conditional on switch points. The latent mixture case has three scripts  (suffixes `_A` and `_B` and `_C`) for inferring group membership, inferring switch points conditional on group membership, then inferring strategy use conditional on group membership and switch points.

For both models, these collections of scripts are separately specified for each relevant sets of candidate strategies. There are currently three such sets: the generic collection TTB, Tally, WADD, and Guess (named`TTBTallyWADDGuess`), and two special sets tailored to the Hilbig and Moshagen strategies (named `GuessTTBTallyWADDWADDprobSaturated`) and the Brusovansky et al strategies (named `TTBEQWTTBWADDGuess`). 

The  Hilbig and Moshagen and Brusovansky et al  also have custom scripts for generating the predictions of the strategies then consider, using the functions `predictHilbigMoshagen.m` and `predictBrusovanskyEtAl.m`It would be possible to consider other sets of strategies by building the appropriate collection of JAGS scripts and MATLAB prediction functions, using these as guides.

There are two parts of the scripts below the user input block that would need updating for new sets of strategies. These parts are when the data structured variable is first being constructed

```
switch modelName
      case 'ssLM_TTBTallyWADDGuess'
         data.stimA = d.stimA(subjectList, :);
         data.stimB = d.stimB(subjectList, :);
      case 'ssLM_GuessTTBTallyWADDWADDprobSaturated'
         data.type = d.itemType(subjectList, :);
      case 'ssLM_TTBEQWTTBWADDGuess'
         data.choice = d.choice(subjectList, :, :);
   end
```

and (more rarely) when the generator functions are established

``` % generator for initialization
   switch modelName
      case 'ss_GuessTTBTallyWADDWADDprobSaturated'
         generator = @()struct('epsilonTmp', 0.5*rand(length(subjectList), 3));
      otherwise
         generator = @()struct('epsilon', 0.5*rand(length(subjectList), 1));
   end
```

## Data

The file `WalshGluck2016Data.mat` has the data for Walsh and Gluck (2016), in a structured variable `d`. The subset of fields used are listed and annotated below. The Hilbig and Moshagen data structure is slightly different, reflecting its reliance on a few item types. In general, though, it is likely a new data set will need to provide this sort of information, and be mapped to the required JAGS input variables by updating the `loadStrategySwitchData` function.
```
d = 
  struct with fields:

          nSubjects: 38                            # number of participants
        nConditions: 2                             # number of experimental conditions		
     conditionNames: {'Aloud'  'Silent'}           # names of conditions
            nTrials: 120                           # number of trials per participant
              nCues: 4                             # number of cues describing alternatives
      nAlternatives: 2                             # number of choice alternatives each trial
          condition: [38×1 double]                 # which condition each participant did
           decision: [38×120 double]               # decision made by participant on trial
            correct: [38×120 logical]              # whether decision was correct
               cues: [16×4 double]                 # description of each stimulus in terms of cues
        searchOrder: [1 2 3 4]                     # order cues are searched (validity-based)
              stimA: [38×120 double]               # which stimulus was option A for each trial
              stimB: [38×120 double]               # which stimulus was option B for each trial
        cueEvidence: [1.3863 1.0986 0.8473 0.8001] # cue validity on additive log-odds scale

```
