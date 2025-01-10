load("channelresponses\Batch3.mat");

%% Section 1: Clustering
successes = zeros([30, 6]);
mdls = cell(6, 1);
idxs = zeros([3360, 6]);
for n = 1:120
    n
    for i = 1:6
        % successes(n, i) = plotclasspredictions(syncresponses(:, [oppadinds; oppoppinds; adadinds]), patterns, i, n);
        % successes(n, i) = plotpcapredictions(syncresponses, patterns, i, n); % this function can be changed to compare different methods
        [successes(n, i), Mdl, idx] = plotclasspredictions(syncresponses, patterns, i, n);
        if n == 120
            mdls{i} = Mdl;
            idxs(:, i) = idx.';
        end
    end
end
plot(1 - successes);
ylim([0 1]);

%% Predict multimodal stimuli
for i = 1:6
    % class = predict(mdls{i}, normalize(singleresponses(:, idxs(1:n, i)), 2));
    class = predict(mdls{i}, singleresponses(:, idxs(1:n, i)));
    subplot(3,2,i);
    plot(class);
    hold on
    scatter(i:6:30, [1 1 1 1 1], 20, 'k', 'filled');
    title(string(i));
end

%% See how human touches are mapped using the space from 6-point presses
% group = [1 2 3 4 5 6];
% group = [group group group group group];

pcanumber = 100;

for probenumber = 1:6
    group = zeros([1 30]);
    for i = 1:5
        group((i-1)*6 + probenumber) = 1;
    end
    subplot(3,2,probenumber);
    [coeff,score] = pca(syncresponses(:, idxs(1:pcanumber, probenumber)));
    % gscatter(score(:, 1), score(:,2), patterns(:,probenumber));
    % hold on
    % scatter(0, 0, 30, 'k', 'filled');
    
    gscatter(coeff(:,1).'*singleresponses(:, idxs(1:pcanumber, probenumber)).',...
        coeff(:,2).'*singleresponses(:, idxs(1:pcanumber, probenumber)).', group);
    title(string(probenumber));
    legend off
end


%% Section 2: single-point WAM predictive + fsrf ranking
normresp = normalize(syncresponses.');

limit = 10;

for probenumber = 1:6
    probenumber
    subplot(2,3,probenumber);
    ind = find(patterns(:,probenumber)==1);
    weights = mean(syncresponses(ind, :));
    
    idx = fsrftest(syncresponses, patterns(:, probenumber));
    
    for i = 1:size(patterns, 1)
        if patterns(i, probenumber) == 1
            col = 'r';
        else
            col = 'b';
        end
        scatter(i, dot(normresp(idx(1:limit), i), weights(idx(1:limit)).'), 20, col, 'filled');
        hold on
    end
end

%% Unsupervised clustering functions
function success = plotpredictions(syncresponses, patterns, probenumber, n)
    idx = fsrftest(syncresponses, patterns(:, probenumber));
    kidx = kmeans(syncresponses(:, idx(1:n)), 2);
    success = max(length(find((kidx-1)==patterns(:, probenumber))), length(find((kidx-1)==1-patterns(:, probenumber))));
end

function success = plotpcapredictions(syncresponses, patterns, probenumber, n)
    idx = fsrftest(syncresponses, patterns(:, probenumber));
    [~,score,~,~,~, ~] = pca(syncresponses(:, idx(1:n)));

    kidx = kmeans(score, 2);
    success = max(length(find((kidx-1)==patterns(:, probenumber))), length(find((kidx-1)==1-patterns(:, probenumber))));
end

%% Supervised clustering (discriminant analysis) functions
function [success, discMdl, idx] = plotclasspredictions(syncresponses, patterns, probenumber, n)
    P = randperm(size(syncresponses, 1));

    % Fit classifier to all except 100 random responses
    XTrain = syncresponses(P(101:end), :);
    YTrain = patterns(P(101:end), probenumber);
    idx = fsrftest(XTrain, YTrain);
    % idx = 1:120;
    XTrain = XTrain(:, idx(1:n));


    % Evaluate on 100 test set
    XTest = syncresponses(P(1:100), idx(1:n));
    YTest = patterns(P(1:100), probenumber);

    % %% Normlize
    % XTrain = normalize(XTrain, 2);
    % XTest = normalize(XTest, 2);

    discMdl = fitcdiscr(XTrain, YTrain);
    class = predict(discMdl, XTest);
    success = length(find(class == YTest))/length(YTest);

end