% LONG TIME TO RUN: PRECALCULATED DATA CAN BE LOADED IN BOTTOM SECTION

load("SavedData/ExtractedPositions.mat"); 
load("SavedData/betterdeltaresponses.mat"); % load data
load("ThomasBoltRankings/gpr_weights.mat"); % load Thomas rankings
responses = deltaresponses;

[~, weightranking] = sort(weights, "descend");

repetitions = 20; % Repetitions for each quantity

quantityelec = [1:9 10:10:240]; % Locations to test
quantity = [quantityelec 250:50:480 500:100:3300 3358];

errorsCombs2 = zeros([length(quantity), repetitions]);
errorsWeights = zeros([length(quantity), repetitions]);

% load("SavedData/TradeoffPlot.mat"); % Continue from previous stopping point

for i = 1:length(quantity)
    quantity(i) % Print current location
    for j = 1:repetitions
        % Seperate 10% test data
        P = randperm(size(positions, 1));
        trainresponses = responses(P(1:4500), :);
        testresponses = responses(P(4501:end), :);
        trainposs = positions(P(1:4500), 1);
        testposs = positions(P(4501:end), 1);


        % Thomas Calculate
        ranking = combs2;
        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        predictions = testresponses(:, ranking(1:quantity(i)))*posfit;
        errorsCombs2(i, j) = mean(predictions-testposs);

        ranking = weightranking;
        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        predictions = testresponses(:, ranking(1:quantity(i)))*posfit;
        errorsWeights(i, j) = mean(predictions-testposs);

    end
    save("SavedData/TradeoffPlotXAxis.mat", "errorsCombs2", "errorsWeights", "quantity", "quantityelec");

end

%% 

% load("SavedData/AnalyticRegressionErrors.mat");
load("SavedData/TradeoffPlotXAxis.mat");
quantityelec = [1:9 10:10:240]; % Locations to test
quantity = [quantityelec 250:50:480 500:100:3300 3358];

% Pseudoplots for legend
plot(nan, nan, 'linewidth', 2, 'Color', 'b');
hold on
plot(nan, nan, 'linewidth', 2, 'Color', 'c');

% Actual plots
addplot(errorsWeights, quantity, 'b');
addplot(errorsCombs2, quantity, 'c');

legend({"Weights"; "Combs2"});
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