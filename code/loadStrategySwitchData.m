function d = loadStrategySwitchData(dataName)
%LOADSTRATEGYSWITCHDATA d = loadStrategySwitchData(dataName)
%   load a data set for strategy switch analysis

% Initial load
switch dataName
    
    case 'WalshGluck2016'
        load ../data/WalshGluck2016Data d
        
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'WalshGluck2016Aloud'
        load ../data/WalshGluck2016Data d
        
        d.nSubjects = 19;
        d.decision = d.decision(1:19, :);
        d.condition = d.condition(1:19, :);
        d.trial = d.trial(1:19, :);
        d.reward = d.reward(1:19, :);
        d.correct = d.correct(1:19, :);
        d.search = d.search(:, :, 1:19, :);
        d.searchAll = d.searchAll(:, :, 1:19, :);
        d.startTime = d.startTime(1:19, :);
        d.searchTime = d.searchTime(:, :, 1:19, :);
        d.stimulus = d.stimulus(:, :, 1:19, :);
        d.layout = d.layout(:, :, 1:19);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'WalshGluck2016Silent'
        load ../data/WalshGluck2016Data d
        
        d.nSubjects = 19;
        d.decision = d.decision(20:38, :);
        d.condition = d.condition(20:38, :);
        d.trial = d.trial(20:38, :);
        d.reward = d.reward(20:38, :);
        d.correct = d.correct(20:38, :);
        d.search = d.search(:, :, 20:38, :);
        d.searchAll = d.searchAll(:, :, 20:38, :);
        d.startTime = d.startTime(20:38, :);
        d.searchTime = d.searchTime(:, :, 20:38, :);
        d.stimulus = d.stimulus(:, :, 20:38, :);
        d.layout = d.layout(:, :, 20:38);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'RieskampOtto2006'
        load ../data/Data_Rieskamp D; d = D; clear D;
        
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'RieskampOttoComp2006'
        load ../data/Data_Rieskamp D; d = D; clear D;
        
        d.nSubjects = 20;
        d.reward = d.reward(1:20, :);
        d.decision = d.decision(1:20, :);
        d.search = d.search(:, :, 1:20, :);
        d.stimulus = d.stimulus(:, :, 1:20, :);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'RieskampOttoNonComp2006'
        load ../data/Data_Rieskamp D; d = D; clear D;
        
        d.nSubjects = 20;
        d.reward = d.reward(21:40, :);
        d.decision = d.decision(21:40, :);
        d.search = d.search(:, :, 21:40, :);
        d.stimulus = d.stimulus(:, :, 21:40, :);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cuesA = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        d.cuesB = unique(squeeze(d.stimulus(:, 2, :))', 'rows');
        d.cues = unique([d.cuesA; d.cuesB], 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'HilbigMoshagen2014'
        load ../data/HilbigMoshagen2016TrialLevel d
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cues = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        % item type 1 is their type 1 with dec = 1, type 2 is their type 1
        % with dec = 2 etc
        tmpDecision = d.decision;
        tmpItemType = d.itemType;
        for i = 1:d.nSubjects
            for j = 1:d.nTrials
                if d.itemType(i, j) == 4
                    tmpDecision(i, j) = 1 - d.decision(i, j);
                    tmpItemType(i, j) = 1;
                elseif d.itemType(i, j) == 5
                    tmpDecision(i, j) = 1 - d.decision(i, j);
                    tmpItemType(i, j) = 2;
                elseif d.itemType(i, j) == 6
                    tmpDecision(i, j) = 1 - d.decision(i, j);
                    tmpItemType(i, j) = 3;
                end
            end
        end
        d.decision = tmpDecision;
        d.itemType = tmpItemType;
        
    case 'NewellShanksAll2003'
        load ../data/NewellShanks2003Data d;
        % low- then high-cost
        reorder = [2, 4, 6, 8, 10, 11, 13, 16, 1, 3, 5, 7, 9, 12, 14, 15];
        d.reward = d.reward(reorder, :);
        d.decision = d.decision(reorder, :);
        d.search = d.search(:, :, reorder, :);
        d.stimulus = d.stimulus(:, :, reorder, :);
        d.condition = d.condition(reorder);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cues = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
        
    case 'NewellShanksHighCost2003'
        load ../data/NewellShanks2003Data d;
        
        keep = [1, 3, 5, 7, 9, 12, 14, 15];
        d.nSubjects = length(keep);
        d.reward = d.reward(keep, :);
        d.decision = d.decision(keep, :);
        d.search = d.search(:, :, keep, :);
        d.stimulus = d.stimulus(:, :, keep, :);
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cues = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
        
    case 'NewellShanksLowCost2003'
        load ../data/NewellShanks2003Data d;
        keep = setdiff(1:16, [1, 3, 5, 7, 9, 12, 14, 15]);
        d.nSubjects = length(keep);
        d.reward = d.reward(keep, :);
        d.decision = d.decision(keep, :);
        d.search = d.search(:, :, keep, :);
        d.stimulus = d.stimulus(:, :, keep, :);% map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.cues = unique(squeeze(d.stimulus(:, 1, :))', 'rows');
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'BrusovanskyEtAl2018ThreeCues'
        load ../data/BrusovanskyEtAl2018 d;
        
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.decision = d.decision(:, :, 1)';
        d.nTrials = d.nTrials;
        d.validity = d.validity{1};
        d.nCues = d.nCues(1);
        d.cues = d.cues{1};
        d.values = d.values{1};
        d.cueEvidence = d.values;
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
        
    case 'BrusovanskyEtAl2018FourCues'
        load ../data/BrusovanskyEtAl2018 d;
        
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.decision = d.decision(:, :, 2)';
        d.nTrials = d.nTrials;
        d.validity = d.validity{2};
        d.nCues = d.nCues(2);
        d.cues = d.cues{2};
        d.values = d.values{2};
        d.cueEvidence = d.values;
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
        
    case 'BrusovanskyEtAl2018FiveCues'
        load ../data/BrusovanskyEtAl2018 d;
        
        % map choices from 1=a, 2=b to 1=a, 0=b
        d.decision(find(d.decision == 2)) = 0;
        d.decision = d.decision(:, :, 3)';
        d.nTrials = d.nTrials;
        d.validity = d.validity{3};
        d.nCues = d.nCues(3);
        d.cues = d.cues{3};
        d.values = d.values{3};
        d.cueEvidence = d.values;
        [~, d.searchOrder] = sort(d.validity, 'descend');
        
    case 'LeeEtAl2014Exp1'
        load ../data/LeeEtAl2014Exp1 d
end

% Secondary process
switch dataName
    case {'BrusovanskyEtAl2018ThreeCues', 'BrusovanskyEtAl2018FourCues', 'BrusovanskyEtAl2018FiveCues'}
        strategyList = {'ttb', 'eqw-ttb', 'wadd', 'guess'};
        nStrategies = numel(strategyList);
        % generate predictions
        d.choice = nan(d.nSubjects, d.nTrials, nStrategies);
        for subjIdx = 1:d.nSubjects
            for trialIdx = 1:d.nTrials
                for stratIdx = 1:nStrategies
                    d.choice(subjIdx, trialIdx, stratIdx) = predictBrusovanskyEtAl(d.values(:, 1, trialIdx, subjIdx), d.values(:, 2, trialIdx, subjIdx), d.cues(:, 1, trialIdx, subjIdx), d.cues(:, 2, trialIdx, subjIdx), d.validity, strategyList{stratIdx});
                end
            end
        end
        
    otherwise
        
        % data
        d.stimA = nan(d.nSubjects, d.nTrials);
        d.stimB =  nan(d.nSubjects, d.nTrials);
        for subjIdx = 1:d.nSubjects
            for trialIdx = 1:d.nTrials
                [~, matchA] = ismember(squeeze(d.stimulus(:, 1, subjIdx, trialIdx))', d.cues, 'rows');
                [~, matchB] = ismember(squeeze(d.stimulus(:, 2, subjIdx, trialIdx))', d.cues, 'rows');
                if (matchA == 0) | (matchB == 0)
                    warning('could not find stimulus');
                    squeeze(d.stimulus(:, 1, subjIdx, trialIdx))'
                                        squeeze(d.stimulus(:, 2, subjIdx, trialIdx))'

                    ismember(squeeze(d.stimulus(:, 1, subjIdx, trialIdx))', d.cues, 'rows')
                    ismember(squeeze(d.stimulus(:, 2, subjIdx, trialIdx))', d.cues, 'rows')

                    pause;
                end
                d.stimA(subjIdx, trialIdx) = matchA;
                d.stimB(subjIdx, trialIdx) = matchB;
            end
        end
        
        d.cueEvidence = log(d.validity) - log(1-d.validity);
end


