load("betterdeltaresponses.mat"); % load data
responses = deltaresponses;

n = 1; % How many of the first PCA channels to average over
repetitions = 20; % Repetitions for each quantity

% quantityelec = [1:9 10:10:240]; % Locations to test
% quantity = [quantityelec 250:50:480 500:100:3300 3358];

% errorselecs1 = zeros([length(quantityelec), repetitions]);
% errorselecs2 = zeros([length(quantityelec), repetitions]);
% errorspca = zeros([length(quantity), repetitions]);
% errorsrandom = zeros([length(quantity), repetitions]);

load("TradeoffPlot.mat"); % Continue from previous stopping point

for i = 44:length(quantity)
    quantity(i) % Print current location
    for j = 1:repetitions
        % Seperate 10% test data
        P = randperm(size(positions, 1));
        trainresponses = responses(P(1:4500), :);
        testresponses = responses(P(4501:end), :);
        trainposs = positions(P(1:4500), :);
        testposs = positions(P(4501:end), :);

        % PCA Calculate
        [coeff,score,latent,tsquared,explained, mu] = pca(trainresponses);
        [~,ranking] = sort(mean(coeff(:,1:n), 2), 'descend');

        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
    
        predictionspca = testresponses(:, ranking(1:quantity(i)))*posfit;
        % errorspca(i, j) = mean(abs(predictionspca-testposs)); % 1D error
        errorspca(i, j) = mean(rssq([predictionspca-testposs].')); % 2D error

        % Random Calculate
        ranking = randperm(3358);

        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
    
        predictionsrandom = testresponses(:, ranking(1:quantity(i)))*posfit;
        errorsrandom(i, j) = mean(rssq([predictionsrandom-testposs].'));


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
    save("TradeoffPlot.mat","errorselecs1", "errorselecs2", "errorspca", "errorsrandom");
end

% Plot trade-off graph
plot(quantity, mean(errorspca, 2));
hold on
plot(quantityelec, mean(errorselecs1, 2));
plot(quantityelec, mean(errorselecs2, 2));
plot(quantity, mean(errorsrandom, 2));
legend({"PCA"; "RMSfirst Analytic"; "Phasefirst Analytics"; "Random"; "quantity"; "quantityelec"});

%% 

load("AnalyticRegressionErrors.mat");
load("TradeoffPlot.mat");

% Pseudoplots for legend
plot(nan, nan, 'linewidth', 2, 'Color', 'b');
hold on
plot(nan, nan, 'linewidth', 2, 'Color', 'c');
plot(nan, nan, 'linewidth', 2, 'Color', 'k');

% Actual plots
addplot(errorspca, quantity, 'b');
addplot(errorsrandom, quantity, 'k');
addplot(errorsallwithphase, 1:240, 'c');

legend({"PCA Ranking"; "Analytic Ranking"; "Random Ranking"});
legend boxoff
ylabel("Localization Error (mm)");
set(gcf, "Position", [449   338   795   420]);

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