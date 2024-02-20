% LONG TIME TO RUN: PRECALCULATED DATA CAN BE LOADED IN BOTTOM SECTION

load("SavedData/ExtractedPositions.mat"); 
load("SavedData/betterdeltaresponses.mat"); % load data
load("ThomasBoltRankings/gpr_weights.mat"); % load Thomas x rankings
[~, weightrankingx] = sort(weights, "descend");
load("ThomasBoltRankings/gprdata_y_res.mat"); % load Thomas y rankings
[~, weightrankingy] = sort(weights, "descend");

load("ThomasBoltRankings/gpr_theta.mat"); % load Thomas theta rankings
[~, weightrankingtheta] = sort(weights, "descend");
load("ThomasBoltRankings/gpr_rho.mat"); % load Thomas rho rankings
[~, weightrankingrho] = sort(weights, "descend");

combinedweights = zeros(size(weightrankingy));
for i = 1:3358
    combinedweights(i) = find(weightrankingtheta==i)+find(weightrankingrho==i);
end
[~, weightranking] = sort(combinedweights, "ascend");

responses = deltaresponses;

% n = 1; % How many of the first PCA channels to average over
repetitions = 20; % Repetitions for each quantity

quantityelec = [1:9 10:10:240]; % Locations to test
quantity = [quantityelec 250:50:480 500:100:3300 3358];

% errorselecs1 = zeros([length(quantityelec), repetitions]);
% errorselecs2 = zeros([length(quantityelec), repetitions]);
% errorspca = zeros([length(quantity), repetitions]);
% errorsrandom = zeros([length(quantity), repetitions]);
% errorsThomas = zeros([length(quantity), repetitions]); %combs2
% errorsThomas2 = zeros([length(quantity), repetitions]); %comb3
% errorsThomasx = zeros([length(quantity), repetitions]); % weights: Trained on x axis only
% errorsThomasy = zeros([length(quantity), repetitions]);
errorsThomasPolweights = zeros([length(quantity), repetitions]);


% load("SavedData/TradeoffPlotPCA_updated.mat"); % Continue from previous stopping point

for i = 1:length(quantity)
    quantity(i) % Print current location
    for j = 1:repetitions
        % Seperate 10% test data
        P = randperm(size(positions, 1));
        trainresponses = responses(P(1:4500), :);
        testresponses = responses(P(4501:end), :);
        trainposs = positions(P(1:4500), :);
        testposs = positions(P(4501:end), :);

        % % PCA Calculate
        % [coeff,score,latent,tsquared,explained, mu] = pca(trainresponses);
        % % [~,ranking] = sort(mean(coeff(:,1:n), 2), 'descend');
        % [~,ranking] = sort(abs(coeff(:,1)), 'descend');
        % 
        % posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % 
        % predictionspca = testresponses(:, ranking(1:quantity(i)))*posfit;
        % % errorspca(i, j) = mean(abs(predictionspca-testposs)); % 1D error
        % errorspca(i, j) = mean(rssq([predictionspca-testposs].')); % 2D error

        % 
        % % Random Calculate
        % ranking = randperm(3358);
        % 
        % posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % 
        % predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorsrandom(i, j) = mean(rssq([predictionsrandom-testposs].'));

        % Thomas Calculate
        % ranking = combs2;
        % posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorsThomas(i, j) = mean(rssq([predictionsrandom-testposs].'));
        % if quantity(i) <= 2060
        %     ranking = comb3;
        %     posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        %     predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        %     errorsThomas2(i, j) = mean(rssq([predictionsrandom-testposs].'));
        % end

        % ranking = weightrankingx;
        % posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorsThomasx(i, j) = mean(rssq([predictionsrandom-testposs].'));

        % ranking = weightrankingy;
        % posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorsThomasy(i, j) = mean(rssq([predictionsrandom-testposs].'));

        ranking = weightranking;
        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorsThomasweights(i, j) = mean(rssq([predictionsrandom-testposs].'));
        errorsThomasPolweights(i, j) = mean(rssq([predictionsrandom-testposs].'));

        % NOW REDUNDANT: SEE TradeoffAnalytic.m
        % if i <= length(quantityelec)
        %     % Analytic Calculate
        %     ranking = [oppadinds; adadinds; oppoppinds;...
        %         oppadinds+3358/2; adadinds+3358/2; oppoppinds+3358/2];
        % 
        %     posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % 
        %     predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
        %     errorselecs1(i, j) = mean(rssq([predictionselecs-testposs].'));
        % 
        %     ranking = [oppadinds+3358/2; adadinds+3358/2; oppoppinds+3358/2;...
        %         oppadinds; adadinds; oppoppinds];
        % 
        %     posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        % 
        %     predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
        %     errorselecs2(i, j) = mean(rssq([predictionselecs-testposs].'));
        % end
    end
    % save("SavedData/TradeoffPlot.mat","errorselecs1", "errorselecs2", "errorspca", "errorsrandom", "errorsThomas", "errorsThomas2", "quantity", "quantityelec");
    save("SavedData/TradeoffPlotTemporary.mat", "errorsThomasPolweights", "quantity", "quantityelec");

end

%% 

load("SavedData/AnalyticRegressionErrors.mat");
load("SavedData/TradeoffPlot.mat");
% load("SavedData/TradeoffPlotPCA_updated.mat");
quantityelec = [1:9 10:10:240]; % Locations to test
quantity = [quantityelec 250:50:480 500:100:3300 3358];

% Pseudoplots for legend
plot(nan, nan, 'linewidth', 2, 'Color', 'b');
hold on
plot(nan, nan, 'linewidth', 2, 'Color', 'c');
plot(nan, nan, 'linewidth', 2, 'Color', 'k');
plot(nan, nan, 'linewidth', 2, 'Color', 'g');
plot(nan, nan, 'linewidth', 2, 'Color', 'r');
plot(nan, nan, 'linewidth', 2, 'Color', 'm');
plot(nan, nan, 'linewidth', 2, 'Color', 'y');

% Actual plots
addplot(errorspca, quantity, 'b');
% addplot(errorsrandom, quantity, 'k');
addplot(errorsThomasPolweights, quantity, 'k');
% addplot(errorsallwithphase, 1:240, 'c');
addplot(errorsThomasweights, quantity, 'c');
addplot(errorsThomas, quantity, 'g');
addplot(errorsThomas2, quantity, 'r');
addplot(errorsThomasx, quantity, 'm');
addplot(errorsThomasy, quantity, 'y');

legend({"PCA Ranking"; "Cartesian"; "Polar"; "combs2"; "comb3"; "x"; "y"});
legend boxoff
ylabel("Localization Error (mm)");
set(gcf, "Position", [449   338   795   420]);
xlim([0 1000]);

% xlim([0 1000]); %See most interesting parts of the plot

function addplot(errors, quantity, col)
    errors = 1000*errors;
    plot(quantity, mean(errors, 2));
    
    x2 = [quantity, fliplr(quantity)];
    inBetween = [mean(errors.')-std(errors.'),...
        fliplr(mean(errors.')+std(errors.'))];
    fill(x2, inBetween, col, 'linestyle', 'none', 'FaceAlpha', 0.5);
    
    hold on
    plot(quantity, mean(errors, 2), 'linewidth', 2, 'color', 'k');
    box off
    set(gca, 'linewidth', 2, 'fontsize', 15);
    % xlim([0 928]);
    xlabel("Number of Channels");

end