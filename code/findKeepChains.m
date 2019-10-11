function [keepChains, bestRhat] = findKeepChains(x, minChains, desiredRhat)
% FINDKEEPCHAINS Find the subset of chains, with at least minChains, that
%                minimizes rHat, from a matrix x with nSamples by nChains
%                the largest number of chains that gets Rhat below desired
%                Rhat is returned
%   requires the gelmanrubin function from trinity
%
%   [keepChains, bestRhat] = findKeepChains(x, minChains, desiredRhat)

[~, nChains] = size(x);
bestRhat = inf;
keepChains = 1:nChains;
done = false;
for numberIdx = nChains:-1:minChains
    combos = nchoosek(1:nChains, numberIdx);
    [nCombos, ~] = size(combos);
    for idx = 1:nCombos
        if done == false
            rhatTmp = gelmanrubin(x(:, combos(idx, :)), 0, 1, 'rhat');
            if rhatTmp < bestRhat
                keepChains = combos(idx, :);
                bestRhat = rhatTmp;
                if bestRhat <= desiredRhat
                    done = true;
                end
            end
        end
    end
end

