load("Data\CombinedSets.mat");

successes = zeros([500, 2]);

for n =  1:500
    n
    for i = 1%1:2
        [successes(n, i), score, YTest] = plotclasspredictions(responses(:, 1:2:end-3), singletargets, i, n);
    end
end

plot(successes);

%% Supervised clustering (discriminant analysis)

function [success, score, YTest] = plotclasspredictions(responses, patterns, predictindex, n, idx)
    %P = randperm(size(responses, 1));
    P = [401:500 1:400 501:600]; % take set in the middle
    % P = [401:500 226:400 501:600]; % ignore anything before 225

    % Fit classifier to all except 100 random responses
    XTrain = responses(P(101:end), :);
    YTrain = patterns(P(101:end), predictindex);

    % F-Test ranking unless something else is given
    if nargin == 4
        idx = fsrftest(XTrain, YTrain);
    end

    XTrain = XTrain(:, idx(1:n));

    % Evaluate on 100 test set
    XTest = responses(P(1:100), idx(1:n));
    YTest = patterns(P(1:100), predictindex);

    % %% Normlize
    % XTrain = normalize(XTrain, 2);
    % XTest = normalize(XTest, 2);

    discMdl = fitcdiscr(XTrain, YTrain, 'prior', 'empirical');
    [class, score] = predict(discMdl, XTest);
    success = length(find(class == YTest))/length(YTest);

end