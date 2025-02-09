% This script tries classifying using linear discriminant analysis
% This was the method which worked well for multitouch on the 2D membrane

% load("Data/Dataset1/CombinedSet1.mat");
% load("Data/Dataset4/CombinedSet4.mat");
% load("Data/Dataset3/CombinedSet3.mat"); % Note this only has 5 locations on each side rather than 10

%% Sided Classification: Try to classify which of 10 locations is being touched on front & back separately

figure();

max_num_channels = 500;
num_columns = 2;

successes = zeros([max_num_channels, num_columns]);
for n =  1:max_num_channels
    n
    for i = 1%:num_columns
        [successes(n, i), score, YTest] = plotclasspredictions(alldata(2:4:end, :), temps, i, n);
    end
end
plot(successes);
% legend({"Front (10 classes)"; "Back (10 classes)"; "Local Temp (2 classes)"});
% ylabel("Classification Rate");
% xlabel("Num Channels");
% title("Sided Classification");

%% Global classification: Each of 100 touch combinations is a different class

figure();

max_num_channels = 100;
num_columns = 1;

successes = zeros([max_num_channels, num_columns]);
for n =  1:max_num_channels
    n
    for i = 1:num_columns
        [successes(n, i), score, YTest] = plotclasspredictions(responses, singletargets, i, n);
    end
end
plot(successes);
ylabel("Classification Rate");
xlabel("Num Channels");
title("Global Classification");


%% Binary classification: treat every touch location as on or off
% Note 0.9 classification rate expected if always predicted off

figure();

max_num_channels = 100;
num_columns = size(binarytargets, 2);

successes = zeros([max_num_channels, num_columns]);
for n =  1:max_num_channels
    n
    for i = 1:num_columns
        [successes(n, i), score, YTest] = plotclasspredictions(responses, binarytargets, i, n);
    end
end
plot(successes);
legend();
ylabel("Classification Rate");
xlabel("Num Channels");
title("Binary Classification");


%% Plot local temperature classification
return % save for figure making
load("Data/Dataset1/CombinedSets.mat");
figure();
successes = zeros([80, 10]);
for n =  1:80
    n
    for i = 1:10
        [successes(n, i), score, YTest] = plotclasspredictions(responses, alltargets(:,3), 1, n);
    end
end
plot(100*mean(successes.'), 'linewidth', 2);
box off
ylim([50 100]);
set(gca, 'fontsize', 15, 'LineWidth', 2);
ylabel("Local Temperature Classification (%)");
xlabel("Number of Channels Monitored");
set(gcf, 'position', [488   266   742   492], 'color', 'w');

%% Supervised clustering (discriminant analysis)

function [success, score, YTest] = plotclasspredictions(responses, patterns, predictindex, n, idx)
    P = randperm(size(responses, 1));
    % P = [401:500 1:400 501:600]; % take set in the middle of dataset1
    % P = [401:500 226:400 501:600]; % ignore anything before 225 from dataset1

    cutoff = 20; % how many to include in test set?

    % % % Fit classifier to all except cutoff random responses
    XTrain = responses(P(cutoff+1:end), :);
    YTrain = patterns(P(cutoff+1:end), predictindex);

    % F-Test ranking unless something else is given
    if nargin == 4
        idx = fsrftest(XTrain, YTrain);
    end

    % Use only the top channels
    XTrain = XTrain(:, idx(1:n));

    % % Evaluate on 100 test set
    XTest = responses(P(1:cutoff), idx(1:n));
    YTest = patterns(P(1:cutoff), predictindex);

    % Sanity check: train & test sets are the same
    % XTrain = responses(P, :); XTest = responses(P, :);
    % YTrain = patterns(P, predictindex); YTest = patterns(P, predictindex);

    % %% Normlize
    % XTrain = normalize(XTrain, 2);
    % XTest = normalize(XTest, 2);

    discMdl = fitcdiscr(XTrain, YTrain, 'prior', 'empirical', 'DiscrimType','pseudolinear');
    [class, score] = predict(discMdl, XTest);
    success = length(find(class == YTest))/length(YTest);

end