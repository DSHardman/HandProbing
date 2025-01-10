load("channelresponses\Batch3.mat");

%% Section 1: Clustering: used in figure
successes = zeros([30, 6]);
mdls = cell(6, 1);
idxs = zeros([3360, 6]);
for n = 1:150 
    n
    for i = 1:6
        % successes(n, i) = plotclasspredictions(syncresponses(:, [oppadinds; oppoppinds; adadinds]), patterns, i, n, 1:120);
        % successes(n, i) = plotpcapredictions(syncresponses, patterns, i, n); % this function can be changed to compare different methods
        [successes(n, i), Mdl, idx] = plotclasspredictions(syncresponses, patterns, i, n);

        if n == 150
            mdls{i} = Mdl;
            idxs(:, i) = idx.';
        end
    end
end
plot(100*successes, 'linewidth', 2);
ylim([0 103]);
set(gca, 'linewidth', 2, 'fontsize', 15); box off
xlabel("N Best Configurations");
ylabel("Location Classification Success (%)");
legend({"A"; "B"; "C"; "D"; "E"; "F"}, 'location', 'se');
legend boxoff

set(gcf, 'position', [488   342   610   416]);

%% Global predictions: used in figure
success = plotglobalpredictions(syncresponses, patterns, 150);
plot(success, 'linewidth', 2, 'color', 1/255*[117 112 179])
hold on
success = plotglobalpredictions(syncresponses(:, [oppadinds; oppoppinds; adadinds]), patterns, 120);
plot(success, 'linewidth', 2, 'color', 1/255*[27 158 119]);

set(gca, 'linewidth', 2, 'fontsize', 15); box off
xlabel("N best configurations");
ylabel("Classification Success (%)");

legend({"All Configurations Available"; "Only Adj/Opp Available"}, 'location', 'se');
legend boxoff
ylim([0 100]);

%% Predict multimodal stimuli: not used
for i = 1:6
    % class = predict(mdls{i}, normalize(singleresponses(:, idxs(1:n, i)), 2));
    class = predict(mdls{i}, singleresponses(:, idxs(1:n, i)));
    subplot(3,2,i);
    plot(class);
    hold on
    scatter(i:6:30, [1 1 1 1 1], 20, 'k', 'filled');
    title(string(i));
end

%% See how human touches are mapped using the space from 6-point presses: used in additional fig...
group = [1 2 3 4 5 6];
group = [group group group group group];

% For doubles testing
% combs = [1 0 0 1 0 0; 0 1 0 0 1 0; 0 0 1 0 0 1; 1 0 0 0 1 0; 1 0 0 0 0 1;...
%     0 1 0 1 0 0; 0 1 0 0 1 0; 0 1 0 0 0 1; 0 0 1 1 0 0; 0 0 1 0 1 0; 0 0 1 0 0 1];
% singleresponses = doubleresponses;

pcanumber = 50;

for probenumber = 1:6
    % group = zeros([1 30]);
    % for i = 1:5
    %     group((i-1)*6 + probenumber) = 1;
    % end
    % group = combs(:, probenumber);

    subplot(1,7,probenumber);

    [coeff,score] = pca(syncresponses(:, idxs(1:pcanumber, probenumber)));
    % gscatter(score(:, 1), score(:,2), patterns(:,probenumber));
    % hold on
    % scatter(0, 0, 30, 'k', 'filled');
    
    gscatter(coeff(:,1).'*singleresponses(:, idxs(1:pcanumber, probenumber)).',...
        coeff(:,2).'*singleresponses(:, idxs(1:pcanumber, probenumber)).', group);
    title(string(probenumber));
    legend off
    set(gca, 'xticklabel', '', 'yticklabel', '', 'xtick', [], 'ytick', []);
    box off
    set(gcf, 'color', 'w');
end

subplot(1,7,7);
title("for legend");
gscatter(coeff(:,1).'*singleresponses(:, idxs(1:pcanumber, probenumber)).',...
        coeff(:,2).'*singleresponses(:, idxs(1:pcanumber, probenumber)).', group);
legend({"A"; "B"; "C"; "D"; "E"; "F"});
set(gcf, 'position', [67 517 1298 162]);

%% Section 2: single-point WAM predictive + fsrf ranking: not used
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

%% Unsupervised clustering functions: not used
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

%% Supervised clustering (discriminant analysis) functions: main workshorse

function [success, discMdl, idx] = plotclasspredictions(syncresponses, patterns, probenumber, n, idx)
    P = randperm(size(syncresponses, 1));

    % Fit classifier to all except 100 random responses
    XTrain = syncresponses(P(101:end), :);
    YTrain = patterns(P(101:end), probenumber);

    % F-Test ranking unless something else is given
    if nargin == 4
        idx = fsrftest(XTrain, YTrain);
    end


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

function success = plotglobalpredictions(syncresponses, patterns, highestnumber)
    
    success = zeros([highestnumber, 1]);

    for n = 1:highestnumber
        n
        % Fit classifier to all except 100 random responses
        P = randperm(size(syncresponses, 1));

        binaryresults = zeros([100, 6]);
        for probenumber = 1:6
            XTrain = syncresponses(P(101:end), :);
            YTrain = patterns(P(101:end), probenumber);
        
            % F-Test ranking unless something else is given
            idx = fsrftest(XTrain, YTrain);
            XTrain = XTrain(:, idx(1:n));
        
        
            % Evaluate on 100 test set
            XTest = syncresponses(P(1:100), idx(1:n));
            YTest = patterns(P(1:100), probenumber);
        
            % %% Normlize
            % XTrain = normalize(XTrain, 2);
            % XTest = normalize(XTest, 2);
        
            discMdl = fitcdiscr(XTrain, YTrain);
            class = predict(discMdl, XTest);
            binaryresults(:, probenumber) = (class == YTest);
        end
        success(n) = length(find(ismember(binaryresults, [1 1 1 1 1 1], "rows")));
    end

end