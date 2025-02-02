side = 1;

% responses = inputs(4:4:end, :);
% responses = inputs(4:4:end, :) - inputs(2:4:end, :);
responses = alldata(1:2:200, :) - alldata(2:2:200, :);
targets = targetpositions(:,2);

% ranking = fsrftest(responses, double(targets(:, side)));
% ranking = randperm(10280);

% targets = classes;
% ranking = fsrftest(responses, targets);
ranking = randperm(size(alldata, 2));

% for i = 1:50
%     plot(alldata(1:100, ranking(i)));
%         for j = 1:25
%         text(4*j-2, alldata(2, ranking(i)), string(targetpositions(j, 2)));
%         end
%     title(string(i));
%     pause()
%     clf
% end

successes = zeros([100, 1]);
for i = 1:100
    P = randperm(length(targets));
    X = responses(:, ranking(1:i));
    % XTrain = X(P(1:round(0.9*length(P))), :);
    % XTest = X(P(round(0.9*length(P)):end), :);
    % YTrain = targets(P(1:round(0.9*length(P))), side);
    % YTest = targets(P(round(0.9*length(P)):end), side);

    XTrain = X(P, :); XTest = X(P, :);
    YTrain = targets(P, side); YTest = targets(P, side);

    discMdl = fitcdiscr(XTrain, YTrain, 'prior', 'empirical', 'discrimType', 'pseudoLinear');
    [class, score] = predict(discMdl, XTest);
    success = length(find(class == YTest))/length(YTest);
    successes(i) = success;
end

plot(successes);
ylim([0 1]);