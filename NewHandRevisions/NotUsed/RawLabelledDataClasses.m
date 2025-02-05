load("Data/Dataset1/CombinedSet1.mat");
% load("Data/Dataset4/CombinedSet4.mat");
% load("Data/Dataset3/CombinedSet3.mat"); % Note this only has 5 locations on each side rather than 10

side = 1;

% responses = inputs(4:4:end, :);
% responses = inputs(4:4:end, :) - inputs(2:4:end, :);
responses = alldata(1:2:end, :) - alldata(2:2:end, :);
targets = targetpositions(:,1);

% ranking = fsrftest(responses, double(targets(:, side)));
% ranking = randperm(10280);

% targets = classes;
ranking = fsrftest(responses, targets);
% ranking = randperm(size(alldata, 2));

for i = 1:50
    plot(responses(1:50, ranking(i)));
        for j = 1:50
        text(j, responses(2, ranking(i)), string(targetpositions(j, 2)));
        end
    title(string(i));
    pause()
    clf
end

% successes = zeros([100, 1]);
% for i = 1:100
%     P = randperm(length(targets));
%     X = responses(:, ranking(1:i));
%     % XTrain = X(P(1:round(0.9*length(P))), :);
%     % XTest = X(P(round(0.9*length(P)):end), :);
%     % YTrain = targets(P(1:round(0.9*length(P))), side);
%     % YTest = targets(P(round(0.9*length(P)):end), side);
% 
%     XTrain = X(P, :); XTest = X(P, :);
%     YTrain = targets(P, side); YTest = targets(P, side);
% 
%     discMdl = fitcdiscr(XTrain, YTrain, 'prior', 'empirical', 'discrimType', 'pseudoLinear');
%     [class, score] = predict(discMdl, XTest);
%     success = length(find(class == YTest))/length(YTest);
%     successes(i) = success;
% end
% 
% plot(successes);
% ylim([0 1]);