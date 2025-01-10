%% Applying fig 3's fingerprinting direct to 6 point data - not used in new figure

% PCA ranking of each - from RMS data only
rankings = zeros([1680, 6]);
for i = 1:6
    % calculate single responses
    singlepattern = zeros([1, 6]);
    singlepattern(i) = 1;
    inds = find(ismember(patterns, singlepattern, "rows"));
    singleresponses = zeros([2*length(inds), 1680]);
    for j = 1:length(inds)
        singleresponses(2*j-1, :) = befores(inds(j), 1:1680);
        singleresponses(2*j, :) = afters(inds(j), 1:1680);
    end

    [coeff,score,latent,tsquared,explained, mu] = pca(singleresponses);
    [~,ranking] = sort(abs(coeff(:,1)), 'descend');
    rankings(:, i) = ranking;
end

% Combine all to determine the best 'average' combinations
combinedweights = zeros([1680, 1]);
for i = 1:1680
    for j = 1:6
        combinedweights(i) = combinedweights(i) + find(rankings(:, j)==i);
    end
end
[~, generalranking] = sort(combinedweights, "ascend");

% Determine uniqueness of specific probes
% i.e. the greatest gap between probe ranking and average ranking
uniquerankings = zeros([1680, 6]);
uniqueness = zeros([1680, 1]);
for n = 1:6
    for i = 1:1680
        uniqueness(i) = find(generalranking==i) - find(rankings(:, n)==i);
    end
    [~, uniquerankings(:, n)] = sort(uniqueness, "descend");
end