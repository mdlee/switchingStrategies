%% strategy switching

clear; close all;

%% User input

% analysis list has data name, model name, subject list, number of rows and columns for plotting
analysisList = {...
 %  {'WalshGluck2016Aloud', 'ss_TTBTallyWADDGuess', 1:19, [4, 2]}, ...
 %  {'WalshGluck2016Silent', 'ss_TTBTallyWADDGuess', 1:19, [4, 2]}, ...
   % {'WalshGluck2016', 'ss_TTBTallyWADDGuess', 1:38, [4, 2]}, ...
  % {'RieskampOttoComp2006', 'ss_TTBTallyWADDGuess', 1:20, [4, 2]}, ...
  % {'RieskampOttoNonComp2006', 'ss_TTBTallyWADDGuess', 1:20, [4, 2]}, ...
  % {'RieskampOtto2006', 'ss_TTBTallyWADDGuess', 1:40, [4, 2]}, ...
   %  {'NewellShanksAll2003', 'ss_TTBTallyWADDGuess', 1:16, [4 2]}, ...
% {'HilbigMoshagen2014', 'ss_GuessTTBTallyWADDWADDprobSaturated', 1:79, [3 2]}, ...
{'BrusovanskyEtAl2018ThreeCues', 'ss_TTBEQWTTBWADDGuess', 1:2, [4 2]}, ...
% {'BrusovanskyEtAl2018FourCues', 'ss_TTBEQWTTBWADDGuess', 1:26, [4 2]}, ...
% {'BrusovanskyEtAl2018FiveCues', 'ss_TTBEQWTTBWADDGuess', 1:26, [4 2]}, ...
   };

doPrint = true;
nMaxSwitches = 5;

%% Other constants
scaleW = 1; scaleH = 0.8; lineWidth = 2;
fontSize = 12;
engine = 'jags';
try load pantoneSpring2015; catch load PantoneSpring2015; end
nAnalyses = numel(analysisList);

%% Loop over analyses
for analysisIdx = 1:nAnalyses
   
   % properties of this analysis
   dataName = analysisList{analysisIdx}{1};
   modelName = analysisList{analysisIdx}{2};
   subjectList = analysisList{analysisIdx}{3};
   nRows =  analysisList{analysisIdx}{4}(1);
   nCols =  analysisList{analysisIdx}{4}(2);
   [strategyList, paramsOne, paramsTwo] = getStrategyList(modelName);
   nStrategies = numel(strategyList);
   nSubjects = length(subjectList);
   
   d = loadStrategySwitchData(dataName);
   
   %% Inference about number and location of switch points
   
   % MCMC properties
   nChains = 6; nBurnin = 5e3; nSamples = 2e3; nThin = 10; doParallel = 1;
   % nChains = 4; nBurnin = 1e3; nSamples = 1e3; nThin = 5;  doParallel = 1;
   nChains = 1; nBurnin = 0; nSamples = 100; nThin = 1;  doParallel = 0;
   
   % generator for initialization
   generator = @()struct('sigmaGamma', rand*0.1+0.1);
   
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
      case 'ss_TTBTallyWADDGuess'
      data.stimA = d.stimA(subjectList, :);  
      data.stimB =  d.stimB(subjectList, :);
      case 'ss_GuessTTBTallyWADDWADDprobSaturated'
      data.type = d.itemType(subjectList, :);
      case 'ss_TTBEQWTTBWADDGuess'
      data.choice = d.choice(subjectList, :, :);
   end
   
   if exist(['storage/' modelName '_' dataName  '.mat'], 'file')
      load(['storage/' modelName '_' dataName], 'chains');
   else
      tic;
      [stats, chains, diagnostics, info] = callbayes(engine, ...
         'model'           ,  [modelName '.txt']                        , ...
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
         'workingdir'      ,  ['tmp/' modelName]                        , ...
         'verbosity'       ,  0                                         , ...
         'saveoutput'      ,  true                                      , ...
         'allowunderscores',  1                                         , ...
         'parallel'        ,  doParallel                                , ...
         'modules'         ,  {'wfComboPack', 'dic'}                    );
      % show timing and save
      fprintf('%s took %f seconds!\n', upper(engine), toc);
      save(['storage/' modelName '_' dataName], 'stats', 'chains', 'diagnostics', 'info');
   end
   
   % check convergence
   disp('Convergence statistics:')
   grtable(chains, 1.1)
   
   % parameter point inferences
   muGamma = codatable(chains, 'muGamma', @mean);
   sigmaGamma = codatable(chains, 'sigmaGamma', @mean);
   gamma = codatable(chains, 'gamma', @mean);
   
   % round tau trials and set those greater than nTrials+1 to nTrials+1
   for subjIdx = 1:nSubjects
      for idx = 1:nMaxSwitches
         eval(sprintf('chains.tau_%d_%d = round(chains.tau_%d_%d);', subjIdx, idx, subjIdx, idx));
         eval(sprintf('chains.tau_%d_%d(find(chains.tau_%d_%d >= d.nTrials)) = d.nTrials;', subjIdx, idx, subjIdx, idx));
      end
   end
   
   % count and find switch points
   nFoundSwitches = nan(length(subjectList), 1);
   nRealSwitches = nan(length(subjectList), 1);
   jointTauMode = d.nTrials*ones(length(subjectList), nMaxSwitches);
   for subjIdx = 1:length(subjectList)
      jointTau = [];
      for j = 1:nMaxSwitches
         eval(['jointTau = [jointTau chains.tau_' int2str(subjIdx) '_' int2str(j) '(:)];']);
      end
      % find the joint mode and remove all values that represent no switch
      [uA, ~, uIdx] = unique(jointTau, 'rows');
      modeIdx = mode(uIdx);
      modeJointTau = uA(modeIdx, :);
      switchPoints = setdiff(modeJointTau, d.nTrials);
      % keep track of real number of switches and add dummy switch is there
      % are none
      nRealSwitches(subjIdx) = length(switchPoints);
      if isempty(switchPoints)
         switchPoints = d.nTrials;
      end
      nFoundSwitches(subjIdx) = length(switchPoints);
      jointTauMode(subjIdx, 1:nFoundSwitches(subjIdx)) = switchPoints;
   end
   
   %% Inference given switch points
   
   % generator for initialization
   switch modelName
      case 'ss_GuessTTBTallyWADDWADDprobSaturated'
      generator = @()struct('epsilonTmp', 0.5*rand(length(subjectList), 3));
      otherwise
      generator = @()struct('epsilon', 0.5*rand(length(subjectList), 1));
   end
   
   % MCMC properties
   nChains = 6; nBurnin = 2e3; nSamples = 1e3; nThin = 10; doParallel = 1;
   
   % Additional data needed by graphical models
   data.nSwitches=  nFoundSwitches;
   data.tau = jointTauMode;
   
   if exist(['storage/' modelName '_' dataName  '_B.mat'], 'file')
      load(['storage/' modelName '_' dataName '_B'], 'chains');
   else
      tic; % start clock
      [stats, chains, diagnostics, info] = callbayes(engine, ...
         'model'           ,  [modelName '_B.txt']                        , ...
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
         'monitorparams'   ,  paramsTwo                                    , ...
         'thin'            ,  nThin                                     , ...
         'workingdir'      ,  ['tmp/' modelName]                        , ...
         'verbosity'       ,  0                                         , ...
         'saveoutput'      ,  true                                      , ...
         'allowunderscores',  1                                         , ...
         'parallel'        ,  doParallel                                , ...
         'modules'         ,  {'wfComboPack', 'dic'}                    );
      % show timing and save
      fprintf('%s took %f seconds!\n', upper(engine), toc); % show timing
      save(['storage/' modelName '_' dataName '_B'], 'stats', 'chains', 'diagnostics', 'info');
   end
   
   % check convergence
   disp('Convergence statistics:')
   grtable(chains, 1.1)
   
   % parameter point inferences
   epsilon = codatable(chains, 'epsilon', @mean);
   z = get_matrix_from_coda(chains, 'z', @mode);
   pi = get_matrix_from_coda(chains, 'pi');
   switch modelName
      case 'ss_GuessTTBTallyWADDWADDprobSaturated', theta = HilbigMoshagenPredictions(epsilon);
      otherwise, theta = reshape(codatable(chains, 'choice', @mean), length(subjectList), d.nTrials, nStrategies);
   end
   
   % write to file latex table of transition probabilities
   outputTransitionTable(dataName, modelName, strategyList, pi);
   
   %% Draw results figures
   for figIdx = 1:ceil(length(subjectList)/(nRows*nCols))
      
      if length(subjectList) >= nRows*nCols
         tmpSubjectList = subjectList(1:nRows*nCols);
      else
         tmpSubjectList = subjectList;
      end
      subjectList = setdiff(subjectList, tmpSubjectList);
      
      % figure and axes
      F = figure(figIdx); clf; hold on;
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
                  if strcmp(modelName, 'ss_GuessTTBTallyWADDWADDprobSaturated')
                     width = scaleW*theta(strategyIdx, d.itemType(subject, trialIdx));
                     height = scaleH*theta(strategyIdx, d.itemType(subject, trialIdx));
                  else
                     width = scaleW*theta(subject, trialIdx, strategyIdx);
                     height = scaleH*theta(subject, trialIdx, strategyIdx);
                  end
               else
                  if strcmp(modelName, 'ss_GuessTTBTallyWADDWADDprobSaturated')
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
         print(['figures/strategiesCompareModels_' dataName '_' int2str(figIdx) '.png'], '-dpng');
         print(['figures/strategiesCompareModels_' dataName '_' int2str(figIdx) '.eps'], '-depsc');
      end
      
   end
   
end
