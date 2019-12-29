%% strategy switching

clear; close all;

%% User input

% analysis list has data name, model name, subject list, number of rows and columns for plotting
analysisList = {...
   %  {'WalshGluck2016', 'ssLM_TTBTallyWADDGuess', 1:38, [4, 2]}; ...
   %  {'WalshGluck2016Aloud', 'ssLM_TTBTallyWADDGuess', 1:19, [4, 2]}; ...
   %  {'WalshGluck2016Silent', 'ssLM_TTBTallyWADDGuess', 1:19, [4, 2]}; ...
   %  {'LeeEtAl2014Exp1', 'ssLM_TTBTallyWADDGuess', 1:30, [4, 2]}; ...
   %  {'RieskampOtto2006', 'ssLM_TTBTallyWADDGuess', 1:40, [4, 2]}; ...
   %  {'RieskampOttoNonComp2006', 'ssLM_TTBTallyWADDGuess', 1:20, [4, 2]}; ...
   %  {'RieskampOttoComp2006', 'ssLM_TTBTallyWADDGuess', 1:20, [4, 2]}; ...
   %  {'NewellShanksAll2003', 'ssLM_TTBTallyWADDGuess', 1:16, [4 2]}; ...
   %  {'NewellShanksHighCost2003', 'ssLM_TTBTallyWADDGuess', 1:8, [4 2]}; ...
   %  {'NewellShanksLowCost2003', 'ssLM_TTBTallyWADDGuess', 1:8, [4 2]}; ...
   %  {'HilbigMoshagen2014', 'ssLM_GuessTTBTallyWADDWADDprobSaturated', 1:79, [3 2]}; ... % 79
   %  {'BrusovanskyEtAl2018ThreeCues', 'ssLM_TTBEQWTTBWADDGuess', 1:26, [4 2]}; ...
   %  {'BrusovanskyEtAl2018FourCues', 'ssLM_TTBEQWTTBWADDGuess', 1:26, [4 2]}; ...
   %  {'BrusovanskyEtAl2018FiveCues', 'ssLM_TTBEQWTTBWADDGuess', 1:26, [4 2]}; ...
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

%% Other constants
scaleW = 1; scaleH = 0.8; lineWidth = 1; overallScale = 0.8;
fontSize = 12;
engine = 'jags';
try load pantoneSpring2015; catch load PantoneSpring2015; end
nAnalyses = numel(analysisList);
height = 0.7;
offset = [2 1 0 -1 -2] * 0.2; % offsets for posteriors in individual plots
offsetOverall = [0 1 -1 2 -2] * 0.15; % offsets for posteriors in overall plots
bfCutoff = 0.01;


%% Loop over analyses
for analysisIdx = 1:nAnalyses
   
   % properties of this analysis
   dataName = analysisList{analysisIdx}{1};
   modelName = analysisList{analysisIdx}{2};
   subjectList = analysisList{analysisIdx}{3};
   nRows =  analysisList{analysisIdx}{4}(1);
   nCols =  analysisList{analysisIdx}{4}(2);
   [strategyList, paramsOne, paramsTwo, paramsThree] = getStrategyList(modelName);
   nStrategies = numel(strategyList);
   nSubjects = length(subjectList);
   
   d = loadStrategySwitchData(dataName);
   
   %% Inference about number and location of switch points
   
   % MCMC properties
   % nChains = 6; nBurnin = 5e3; nSamples = 1e3; nThin = 100; doParallel = 1;
   % nChains = 6; nBurnin = 5e3; nSamples = 2e3; nThin = 10; doParallel = 1;
   nChains = 6; nBurnin = 5e3; nSamples = 1e3; nThin = 10; doParallel = 1;
   % nChains = 4; nBurnin = 1e3; nSamples = 1e3; nThin = 5;  doParallel = 1;
   % nChains = 1; nBurnin = 0; nSamples = 3; nThin = 1;  doParallel = 0;
   
   % generator for initialization
   generator = @()struct('sigmaGamma', rand(1, 2)*0.1 + 0.1);
   
   % input for graphical model
   data = struct(...
      'nSubjects'   , nSubjects                   , ...
      'decision'    , d.decision(subjectList, :)  , ...
      'nTrials'     , d.nTrials                   , ...
      'nStrategies' , nStrategies                 , ...
      'cues'        , d.cues                      , ...
      'searchOrder' , d.searchOrder               , ...
      'cueEvidence' , d.cueEvidence               , ...
      'nMaxSwitches', nMaxSwitches                );
   
   switch modelName
      case 'ssLM_TTBTallyWADDGuess'
         data.stimA = d.stimA(subjectList, :);
         data.stimB = d.stimB(subjectList, :);
      case 'ssLM_GuessTTBTallyWADDWADDprobSaturated'
         data.type = d.itemType(subjectList, :);
      case 'ssLM_TTBEQWTTBWADDGuess'
         data.choice = d.choice(subjectList, :, :);
   end
   
   if exist(['storage/' modelName '_' dataName  '_A.mat'], 'file')
      load(['storage/' modelName '_' dataName '_A'], 'chains');
   else
      tic;
      [stats, chains, diagnostics, info] = callbayes(engine, ...
         'model'           ,  [modelName '_A.txt']                      , ...
         'data'            ,  data                                      , ...
         'outputname'      ,  'samples'                                 , ...
         'init'            ,  generator                                 , ...
         'datafilename'    ,  modelName                                 , ...
         'initfilename'    ,  modelName                                 , ...
         'scriptfilename'  ,  modelName                                 , ...
         'logfilename'     ,  modelName                                 , ...
         'nchains'         ,  nChains                                   , ...
         'nburnin'         ,  nBurnin                                   , ...
         'nsamples'        ,  nSamples                                  , ...
         'monitorparams'   ,  paramsOne                                 , ...
         'thin'            ,  nThin                                     , ...
         'workingdir'      ,  ['tmpOD/' modelName]                        , ...
         'verbosity'       ,  0                                         , ...
         'saveoutput'      ,  true                                      , ...
         'allowunderscores',  1                                         , ...
         'parallel'        ,  doParallel                                , ...
         'modules'         ,  {'wfComboPack', 'dic'}                    );
      % show timing and save
      fprintf('%s took %f seconds!\n', upper(engine), toc);
      save(['storage/' modelName '_' dataName '_A'], 'stats', 'chains', 'diagnostics', 'info');
   end
   
   % find the subset of chains with acceptable MCMC convergence
   [keepDevianceChains, devianceRhat] = findKeepChains(chains.deviance, 2, 1.05);
   %     nChains = length(keepDevianceChains);
   fields = fieldnames(chains);
   for i = 1:numel(fields)
      chains.(fields{i}) = chains.(fields{i})(:, keepDevianceChains);
   end
   
   % check convergence
   disp('Convergence statistics:')
   grtable(chains, 1.1)
   
   % parameter point inferences
   xMode = codatable(chains, 'x', @mode);
   
   % bayes factor
   countLow = mean(chains.phi(:) < bfCutoff);
   countHigh = mean(chains.phi(:) > 1 - bfCutoff);
   bfLow = log(countLow) - log(bfCutoff);
   bfHigh = log(countHigh) - log(bfCutoff);
   
   % communicate results
   fprintf('--------------------------------------------\n');
   fprintf('A script done, modal group assignments made:\n');
   for idx = 1:nSubjects
      fprintf('Participant %d assigned to group %d\n', idx, xMode(idx));
   end
   fprintf('Number participants in each group is %d and %d\n', length(find(xMode == 0)), length(find(xMode == 1)));
   fprintf('log Bayes factor in favor of null is %1.1f (for phi = 0) and %1.1f (for phi = 1)\n', bfLow, bfHigh);
   fprintf('Base-rate for high gamma is %1.2f [%1.2f, %1.2f]\n', mean(chains.phi(:)), prctile(chains.phi(:), [2.5 97.5]));
   
   %% Inference about switch points given group assignments
   
   % group assignments are now observed, to condition on mode
   data.x = xMode;
   
   if exist(['storage/' modelName '_' dataName  '_B.mat'], 'file')
      load(['storage/' modelName '_' dataName '_B'], 'chains');
   else
      tic;
      [stats, chains, diagnostics, info] = callbayes(engine, ...
         'model'           ,  [modelName '_B.txt']                      , ...
         'data'            ,  data                                      , ...
         'outputname'      ,  'samples'                                 , ...
         'init'            ,  generator                                 , ...
         'datafilename'    ,  modelName                                 , ...
         'initfilename'    ,  modelName                                 , ...
         'scriptfilename'  ,  modelName                                 , ...
         'logfilename'     ,  modelName                                 , ...
         'nchains'         ,  nChains                                   , ...
         'nburnin'         ,  nBurnin                                   , ...
         'nsamples'        ,  nSamples                                  , ...
         'monitorparams'   ,  paramsTwo                                 , ...
         'thin'            ,  nThin                                     , ...
         'workingdir'      ,  ['tmpOD/' modelName]                        , ...
         'verbosity'       ,  0                                         , ...
         'saveoutput'      ,  true                                      , ...
         'allowunderscores',  1                                         , ...
         'parallel'        ,  doParallel                                , ...
         'modules'         ,  {'wfComboPack', 'dic'}                    );
      % show timing and save
      fprintf('%s took %f seconds!\n', upper(engine), toc);
      save(['storage/' modelName '_' dataName '_B'], 'stats', 'chains', 'diagnostics', 'info');
   end
   
   % parameter point inferences
   muGamma = get_matrix_from_coda(chains, 'muGamma', @mean);
   sigmaGamma = get_matrix_from_coda(chains, 'sigmaGamma', @mean);
   gamma = codatable(chains, 'gamma', @mean);
   fprintf('Modal group gammas are is %1.2f [%1.2f, %1.2f] and %1.2f [%1.2f, %1.2f]\n', muGamma(1), prctile(chains.muGamma_1(:), [2.5 97.5]), muGamma(2), prctile(chains.muGamma_2(:), [2.5 97.5]));
   fprintf('Standard deviations are is %1.2f and %1.2f\n', sigmaGamma);
   
   % round tau trials and set those greater than nTrials+1 to nTrials+1
   for subjIdx = 1:nSubjects
      for idx = 1:nMaxSwitches
         eval(sprintf('chains.tau_%d_%d = round(chains.tau_%d_%d);', subjIdx, idx, subjIdx, idx));
         eval(sprintf('chains.tau_%d_%d(find(chains.tau_%d_%d >= d.nTrials)) = d.nTrials;', subjIdx, idx, subjIdx, idx));
      end
   end
   
   % count and find switch points
   nPosteriors = nan(length(subjectList), 1);
   nFoundSwitches = nan(length(subjectList), maxPosteriors);
   nRealSwitches = nan(length(subjectList), maxPosteriors);
   massPosteriors = nan(length(subjectList), maxPosteriors);
   jointTauMode = d.nTrials*ones(length(subjectList), nMaxSwitches, maxPosteriors);
   for subjIdx = 1:length(subjectList)
      jointTau = [];
      for j = 1:nMaxSwitches
         eval(['jointTau = [jointTau chains.tau_' int2str(subjIdx) '_' int2str(j) '(:)];']);
      end
      % find the joint mode and remove all values that represent no switch
      [uA, ~, uIdx] = unique(jointTau, 'rows');
      tmpTable = tabulate(uIdx);
      massCurrentPosterior = tmpTable(:, 3);
      [massCurrentPosterior, ind] = sort(massCurrentPosterior, 'descend');
      uA = uA(ind, :);
      % find the posterior masses above ratio, up to maximum allowed
      matchPosteriorsInd = find(massCurrentPosterior >= posteriorMassRatio*massCurrentPosterior(1));
      if length(matchPosteriorsInd) > maxPosteriors
         matchPosteriorsInd = matchPosteriorsInd(1:maxPosteriors);
      end
      nPosteriors(subjIdx) = length(matchPosteriorsInd);
      % details on the considered posteriors
      for idx = 1:nPosteriors(subjIdx)
         massPosteriors(subjIdx, idx) = massCurrentPosterior(matchPosteriorsInd(idx));
         modeJointTau = uA(matchPosteriorsInd(idx), :);
         switchPoints = setdiff(modeJointTau, d.nTrials);
         % keep track of real number of switches and add dummy switch if there are none
         nRealSwitches(subjIdx, idx) = length(switchPoints);
         if isempty(switchPoints)
            switchPoints = d.nTrials;
         end
         nFoundSwitches(subjIdx, idx) = length(switchPoints);
         jointTauMode(subjIdx, 1:nFoundSwitches(subjIdx, idx), idx) = switchPoints;
      end
   end
   
   %% Inference about strategy use, given switch points, with a full subject run for each possible posterior
   
   % generator for initialization
   switch modelName
      case 'ssLM_GuessTTBTallyWADDWADDprobSaturated'
         generator = @()struct('epsilonTmp', 0.5*rand(length(subjectList), 3));
      otherwise
         generator = @()struct('epsilon', 0.5*rand(length(subjectList), 1));
   end
   
   
   for posteriorIdx = 1:max(nPosteriors)
      
      % which posterior to use for each subject
      usePosterior = min(nPosteriors, posteriorIdx);
      
      % Additional data needed by graphical models
      for subjIdx = 1:length(subjectList)
         data.nSwitches(subjIdx) =  nFoundSwitches(subjIdx, usePosterior(subjIdx));
         data.tau(subjIdx, :) = jointTauMode(subjIdx, :, usePosterior(subjIdx));
      end
      
      if exist(['storage/' modelName '_' dataName  '_C_posterior' int2str(posteriorIdx) '.mat'], 'file')
         load(['storage/' modelName '_' dataName '_C_posterior' int2str(posteriorIdx)'], 'chains');
      else
         tic; % start clock
         [stats, chains, diagnostics, info] = callbayes(engine, ...
            'model'           ,  [modelName '_C.txt']                        , ...
            'data'            ,  data                                      , ...
            'outputname'      ,  'samples'                                 , ...
            'init'            ,  generator                                 , ...
            'datafilename'    ,  modelName                                 , ...
            'initfilename'    ,  modelName                                 , ...
            'scriptfilename'  ,  modelName                                 , ...
            'logfilename'     ,  modelName                                 , ...
            'nchains'         ,  nChains                                   , ...
            'nburnin'         ,  nBurnin                                   , ...
            'nsamples'        ,  nSamples                                  , ...
            'monitorparams'   ,  paramsThree                               , ...
            'thin'            ,  nThin                                     , ...
            'workingdir'      ,  ['tmpOD/' modelName]                        , ...
            'verbosity'       ,  0                                         , ...
            'saveoutput'      ,  true                                      , ...
            'allowunderscores',  1                                         , ...
            'parallel'        ,  doParallel                                , ...
            'modules'         ,  {'wfComboPack', 'dic'}                    );
         % show timing and save
         fprintf('%s took %f seconds!\n', upper(engine), toc); % show timing
         save(['storage/' modelName '_' dataName '_C_posterior' int2str(posteriorIdx)'], 'stats', 'chains', 'diagnostics', 'info');
      end
      
   end
   
   % find the subset of chains with acceptable MCMC convergence
   [keepDevianceChains, devianceRhat] = findKeepChains(chains.deviance, 2, 1.05);
   nChains = length(keepDevianceChains);
   fields = fieldnames(chains);
   for i = 1:numel(fields)
      chains.(fields{i}) = chains.(fields{i})(:, keepDevianceChains);
   end
   
   % check convergence
   disp('Convergence statistics:')
   grtable(chains, 1.1)
   
   % parameter point inferences
   epsilon = codatable(chains, 'epsilon', @mean);
   z = get_matrix_from_coda(chains, 'z', @mode);
   pi = get_matrix_from_coda(chains, 'pi');
   piPrime = codatable(chains, 'piPrime', @mean);
   switch modelName
      case 'ssLM_GuessTTBTallyWADDWADDprobSaturated'
         theta = predictHilbigMoshagen(epsilon);
      otherwise
         theta = reshape(codatable(chains, 'choice', @mean), length(subjectList), d.nTrials, nStrategies);
   end
   
   fprintf('piPrime = '); fprintf('%1.2f, ', piPrime); fprintf('\n');
   % write to file latex table of transition probabilities
   if printTable
      outputTransitionTable(dataName, modelName, strategyList, pi);
   end
   
   if printCombinedTable
      storePi{analysisIdx} = pi;
   end
   
   %% Draw individual results figures
   if drawIndividuals
      for figIdx = 1:ceil(length(subjectList)/(nRows*nCols))
         
         if length(subjectList) >= nRows*nCols
            tmpSubjectList = subjectList(1:nRows*nCols);
         else
            tmpSubjectList = subjectList;
         end
         subjectList = setdiff(subjectList, tmpSubjectList);
         
         % figure and axes
         F = figure(analysisIdx*10+figIdx); clf; hold on;
         set(F, ...
            'renderer'          , 'painters'        , ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.6 0.7] , ...
            'paperpositionmode' , 'auto'            );
         
         for subjectIdx = 1:length(tmpSubjectList)
            
            subject = tmpSubjectList(subjectIdx);
            
            subplot(nRows, nCols, subjectIdx); cla; hold on;
            set(gca, ...
               'xlim'          , [0 d.nTrials+1]     , ...
               'xtick'         , [1 d.nTrials]       , ...
               'ylim'          , [0 nStrategies+1]   , ...
               'ytick'         , 1:nStrategies       , ...
               'yticklabel'    , strategyList        , ...
               'box'           , 'off'               , ...
               'tickdir'       , 'out'               , ...
               'layer'         , 'top'               , ...
               'ticklength'    , [0.01 0]            , ...
               'fontsize'      ,  fontSize           );
            
            title(sprintf('Participant %d', subject), ...
               'fontsize'   , fontSize+ 2 , ...
               'fontweight' , 'normal'   );
            
            for trialIdx = 1:d.nTrials
               for strategyIdx = 1:nStrategies
                  if d.decision(subject, trialIdx) == 1
                     if strcmp(modelName, 'ssLM_GuessTTBTallyWADDWADDprobSaturated')
                        width = scaleW*theta(strategyIdx, d.itemType(subject, trialIdx));
                        height = scaleH*theta(strategyIdx, d.itemType(subject, trialIdx));
                     else
                        width = scaleW*theta(subject, trialIdx, strategyIdx);
                        height = scaleH*theta(subject, trialIdx, strategyIdx);
                     end
                  else
                     if strcmp(modelName, 'ssLM_GuessTTBTallyWADDWADDprobSaturated')
                        width = scaleW*(1-theta(strategyIdx, d.itemType(subject, trialIdx)));
                        height = scaleH*(1-theta(strategyIdx, d.itemType(subject, trialIdx)));
                     else
                        width = scaleW*(1-theta(subject, trialIdx, strategyIdx));
                        height = scaleH*(1-theta(subject, trialIdx, strategyIdx));
                     end
                  end
                  rectangle(...
                     'position'  , [trialIdx-width/2 strategyIdx-height/2 width height] , ...
                     'facecolor' , getStrategyColor(strategyList{strategyIdx}, pantone) , ...
                     'edgecolor' , 'none'                                               );
               end
            end
            
            z = [z nan(nSubjects, 1)];
            for trialIdx = 1:d.nTrials
               for strategyIdx = 1:nStrategies
                  jointTauModeTmp = unique(jointTauMode(subject, :));
                  if ~isempty(jointTauModeTmp)
                     current = 0;
                     for tauIdx = 1:length(jointTauModeTmp)
                        if jointTauModeTmp(tauIdx) ~= d.nTrials
                           plot(ones(1, 2)*jointTauModeTmp(tauIdx)+0.5, [0 nStrategies+1], 'k--');
                        end
                        plot([current jointTauModeTmp(tauIdx)]+0.5, [z(subject, tauIdx) z(subject, tauIdx)], 'w-', ...
                           'linewidth', lineWidth+1);
                        plot([current jointTauModeTmp(tauIdx)]+0.5, [z(subject, tauIdx) z(subject, tauIdx)], 'k-', ...
                           'linewidth', lineWidth);
                        current = jointTauModeTmp(tauIdx);
                     end
                     plot([current d.nTrials]+0.5, [z(subject, tauIdx+1) z(subject, tauIdx+1)], 'w-', ...
                        'linewidth', lineWidth+1);
                     plot([current d.nTrials]+0.5, [z(subject, tauIdx+1) z(subject, tauIdx+1)], 'k-', ...
                        'linewidth', lineWidth);
                  end
               end
            end
            
            pause(0.1);
            
         end
         
         % print
         if doPrint
            print(['figures/LMindividuals_' dataName '_' int2str(figIdx) '.png'], '-dpng');
            print(['figures/LMindividuals_' dataName '_' int2str(figIdx) '.eps'], '-depsc');
         end
         
      end
   end
   
   %% Draw change results figures
   if drawChange
      
      mostRealSwitches = max(nRealSwitches, [], 2);
      
      subjectListChangeIdx = find(mostRealSwitches > 0);
      subjectListChange = subjectList(subjectListChangeIdx);
      
      for figIdx = 1:ceil(length(subjectListChange)/(nRows*nCols))
         
         if length(subjectListChange) >= nRows*nCols
            tmpSubjectList = subjectListChange(1:nRows*nCols);
            tmpSubjectListIdx = subjectListChangeIdx(1:nRows*nCols);
         else
            tmpSubjectList = subjectListChange;
            tmpSubjectListIdx = subjectListChangeIdx;
         end
         subjectListChange = setdiff(subjectListChange, tmpSubjectList);
         subjectListChangeIdx = setdiff(subjectListChangeIdx, tmpSubjectListIdx);
         
         % figure and axes
         F = figure(100+analysisIdx*10+figIdx); clf; hold on;
         set(F, ...
            'renderer'          , 'painters'        , ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.6 0.7] , ...
            'paperpositionmode' , 'auto'            );
         
         for subjectIdx = 1:length(tmpSubjectList)
            
            subject = tmpSubjectList(subjectIdx);
            
            subplot(nRows, nCols, subjectIdx); cla; hold on;
            set(gca, ...
               'xlim'          , [0 d.nTrials+1]                      , ...
               'xtick'         , highlightTrials(dataName, d.nTrials) , ...
               'ylim'          , [0 nStrategies+1]                    , ...
               'ytick'         , 1:nStrategies                        , ...
               'yticklabel'    , strategyList                         , ...
               'box'           , 'off'                                , ...
               'tickdir'       , 'out'                                , ...
               'layer'         , 'top'                                , ...
               'ticklength'    , [0.01 0]                             , ...
               'fontsize'      ,  fontSize                            );
            
            title(sprintf('Participant %d', subject), ...
               'fontsize'   , fontSize+ 2 , ...
               'fontweight' , 'normal'   );
            
            % data
            for trialIdx = 1:d.nTrials
               for strategyIdx = 1:nStrategies
                  if d.decision(subject, trialIdx) == 1
                     if strcmp(modelName, 'ssLM_GuessTTBTallyWADDWADDprobSaturated')
                        width = scaleW*theta(strategyIdx, d.itemType(tmpSubjectListIdx(subjectIdx), trialIdx));
                        height = scaleH*theta(strategyIdx, d.itemType(tmpSubjectListIdx(subjectIdx), trialIdx));
                     else
                        width = scaleW*theta(tmpSubjectListIdx(subjectIdx), trialIdx, strategyIdx);
                        height = scaleH*theta(tmpSubjectListIdx(subjectIdx), trialIdx, strategyIdx);
                     end
                  else
                     if strcmp(modelName, 'ssLM_GuessTTBTallyWADDWADDprobSaturated')
                        width = scaleW*(1-theta(strategyIdx, d.itemType(tmpSubjectListIdx(subjectIdx), trialIdx)));
                        height = scaleH*(1-theta(strategyIdx, d.itemType(tmpSubjectListIdx(subjectIdx), trialIdx)));
                     else
                        width = scaleW*(1-theta(tmpSubjectListIdx(subjectIdx), trialIdx, strategyIdx));
                        height = scaleH*(1-theta(tmpSubjectListIdx(subjectIdx), trialIdx, strategyIdx));
                     end
                  end
                  rectangle(...
                     'position'  , [trialIdx-width/2 strategyIdx-height/2 width height] , ...
                     'facecolor' , getStrategyColor(strategyList{strategyIdx}, pantone) , ...
                     'edgecolor' , 'none'                                               );
               end
            end
            
            for posteriorIdx = 1:nPosteriors(tmpSubjectListIdx(subjectIdx))
               
               load(['storage/' modelName '_' dataName '_C_posterior' int2str(posteriorIdx)'], 'chains');
               z = get_matrix_from_coda(chains, 'z', @mode);
               z = [z nan(nSubjects, 1)];
               jointTauModeTmp = unique(jointTauMode(tmpSubjectListIdx(subjectIdx), :, posteriorIdx));
               current = 0;
               for tauIdx = 1:length(jointTauModeTmp)
                  if jointTauModeTmp(tauIdx) ~= d.nTrials
                     plot(ones(1, 2)*jointTauModeTmp(tauIdx)+0.5, [z(tmpSubjectListIdx(subjectIdx), tauIdx) z(tmpSubjectListIdx(subjectIdx), tauIdx+1)] + offset(posteriorIdx), 'k-', ...
                        'linewidth', lineWidth);
                  end
                  plot([current jointTauModeTmp(tauIdx)]+0.5, [z(tmpSubjectListIdx(subjectIdx), tauIdx) z(tmpSubjectListIdx(subjectIdx), tauIdx)] + offset(posteriorIdx), 'k-', ...
                     'linewidth', lineWidth);
                  current = jointTauModeTmp(tauIdx);
               end
               plot([current d.nTrials]+0.5, [z(tmpSubjectListIdx(subjectIdx), tauIdx+1) z(tmpSubjectListIdx(subjectIdx), tauIdx+1)] + offset(posteriorIdx), 'k-', ...
                  'linewidth', lineWidth);
               
               pause(0.1);
            end
            
         end
         
         % print
         if doPrint
            print(['figures/LMindividualsChange_' dataName '_' int2str(figIdx) '.png'], '-dpng');
            print(['figures/LMindividualsChange_' dataName '_' int2str(figIdx) '.eps'], '-depsc');
         end
         
      end
   end
   
   %% Overall figure
   if drawOverall
      
      % set position based on number of participants
      widthHeight = [0.4 0.1+0.015*length(subjectList)]*1.25;
      
      % figure and axes
      F = figure(200+analysisIdx); clf; hold on;
      set(F, ...
         'renderer'          , 'painters'        , ...
         'color'             , 'w'               , ...
         'units'             , 'normalized'      , ...
         'position'          , [0.2 0.2 widthHeight] , ...
         'paperpositionmode' , 'auto'            );
      
      set(gca, ...
         'units'         , 'normalized'                           , ...
         'position'      , [0.1 0.1 0.85 0.8]                     , ...
         'xlim'          , [0 d.nTrials+1]                        , ...
         'xtick'         , highlightTrials(dataName, d.nTrials)   , ...
         'ylim'          , [0.5 length(subjectList)+0.5]          , ...
         'ytick'         , 1:nSubjects                            , ...
         'ydir'          , 'rev'                                  , ...
         'box'           , 'off'                                  , ...
         'tickdir'       , 'out'                                  , ...
         'layer'         , 'top'                                  , ...
         'ticklength'    , [0.01 0]                               , ...
         'fontsize'      ,  fontSize                              );
      
      xlabel('Trials', 'fontsize', fontSize + 2, 'vert', 'bot');
      ylabel('Participants', 'fontsize', fontSize + 2);
      
      for subjectIdx = 1:length(subjectList)
         subject = subjectList(subjectIdx);
         
         for posteriorIdx = 1:nPosteriors(subjectIdx)
            
            load(['storage/' modelName '_' dataName '_C_posterior' int2str(posteriorIdx)'], 'chains');
            z = get_matrix_from_coda(chains, 'z', @mode);
            z = [z nan(nSubjects, 1)];
            jointTauModeTmp = unique([jointTauMode(subjectIdx, :, posteriorIdx) d.nTrials]);
            current = 0;
            for tauIdx = 1:length(jointTauModeTmp)
               left = current + 0.5;
               bottom = subjectIdx - overallScale/2 + (posteriorIdx-1)/nPosteriors(subjectIdx)*overallScale;
               width = jointTauModeTmp(tauIdx) - current;
               height = overallScale/nPosteriors(subjectIdx);
               rectangle('position', [left bottom width height], ...
                  'facecolor' , getStrategyColor(strategyList{z(subjectIdx, tauIdx)}, pantone)  , ...
                  'edgecolor' , 'none'                                                          );
               current = jointTauModeTmp(tauIdx);
            end
            pause(0.1);
         end
         
      end
      
      for idx = 1:nStrategies
         H(idx) = plot(-100, -100, 'o', ...
            'markerfacecolor' , getStrategyColor(strategyList{idx}, pantone) , ...
            'markeredgecolor' , 'w'                                                         , ...
            'markersize'      , 12                                                          );
      end
      legend(H, strategyList, ...
         'location' , 'eastoutside' , ...
         'fontsize' , fontSize + 2  , ...
         'box'      , 'off'         );
      
      % Print
      if doPrint
         print(['figures/LMall_' dataName '.png'], '-dpng');
         print(['figures/LMall_' dataName '.eps'], '-depsc');
      end
      
   end
   
   
end

if printCombinedTable
   outputCombinedTransitionTable(dataName, modelName, strategyList, storePi);
end

