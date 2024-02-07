load("betterdeltaresponses.mat"); % load data
responses = deltaresponses;

n = 1; % How many of the first PCA channels to average over
repetitions = 20; % Repetitions for each quantity

quantity = 1:240; % Locations to test

errorsoppopp = zeros([length(quantity), repetitions]);
errorsoppad = zeros([length(quantity), repetitions]);
errorsadad = zeros([length(quantity), repetitions]);
errorsall = zeros([length(quantity), repetitions]);
errorsallwithphase = zeros([length(quantity), repetitions]);

errorsNoppopp = zeros([length(quantity), repetitions]);
errorsNoppad = zeros([length(quantity), repetitions]);
errorsNadad = zeros([length(quantity), repetitions]);

for i = 1:length(quantity)
    quantity(i) % Print current location
    for j = 1:repetitions
        % Seperate 10% test data
        P = randperm(size(positions, 1));
        trainresponses = responses(P(1:4500), :);
        testresponses = responses(P(4501:end), :);
        trainposs = positions(P(1:4500), :);
        testposs = positions(P(4501:end), :);


        % Analytic Calculate
        %ALLWITHPHASE
        ranking1 = [oppadinds; oppoppinds; adadinds];
        ranking2 = [oppadinds+1679; oppoppinds+1679; adadinds+1679];
        ranking = zeros([length(ranking1)*2, 1]);
        for k = 1:length(ranking1)
            ranking(2*k-1) = ranking1(k);
            ranking(2*k) = ranking2(k);
        end
        posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
        predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
        errorsallwithphase(i, j) = mean(rssq([predictionselecs-testposs].'));

        %ALL
        if i < 121
            ranking = [oppadinds; oppoppinds; adadinds];
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsall(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %OPOP
        if i < 49
            ranking = oppoppinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsoppopp(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %ADAD
        if i < 41
            ranking = adadinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsadad(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %OPAD
        if i < 33
            ranking = oppadinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsoppad(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %NOPOP
        if i < 13
            ranking = Noppoppinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsNoppopp(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %NADAD
        if i < 36
            ranking = Nadadinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsNadad(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

        %NOPAD
        if i < 17
            ranking = Noppadinds;
            posfit = trainresponses(:, ranking(1:quantity(i)))\trainposs;
            predictionselecs = testresponses(:, ranking(1:quantity(i)))*posfit;
            errorsNoppad(i, j) = mean(rssq([predictionselecs-testposs].'));
        end

    end
end

%% Create plots

load("AnalyticRegressionErrors.mat");

% Pseudoplots for legend
plot(nan, nan, 'linewidth', 2, 'Color', 'r');
hold on
plot(nan, nan, 'linewidth', 2, 'Color', 'g');
plot(nan, nan, 'linewidth', 2, 'Color', 'b');
plot(nan, nan, 'linewidth', 2, 'Color', 'm');
plot(nan, nan, 'linewidth', 2, 'Color', 'c');

% Actually plot
addplot(errorsall(1:120, :), 1:120, 'm');
addplot(errorsoppopp(1:48, :), 1:48, 'b');
addplot(errorsadad(1:40, :), 1:40, 'g');
addplot(errorsoppad(1:32, :), 1:32, 'r');
addplot(errorsallwithphase, 1:240, 'c');

legend({"OP AD"; "AD AD"; "OP OP"; "All (OP AD + OP OP + AD AD)"; "All with phase"});
legend boxoff
ylabel("Localization Error (mm)");
set(gcf, "Position", [449   338   795   420]);

% No exciting differences made by removing redundant combinations - do not
% consider further
% addplot(errorsNoppopp, quantity, 'c');
% addplot(errorsNadad, quantity, 'm');
% addplot(errorsNoppad, quantity, 'y');

function addplot(errors, quantity, col)
    errors = errors*1000;
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