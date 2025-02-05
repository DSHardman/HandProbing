% load("Data/Dataset2/CombinedSet2.mat");
load("Data/Dataset5/CombinedSet5Cleaned.mat");

%% F-Test ranking for x & y positions on front & back
ranking1 = fsrftest(responses, targetpositions(:, 1));
ranking2 = fsrftest(responses, targetpositions(:, 2));
ranking3 = fsrftest(responses, targetpositions(:, 3));
ranking4 = fsrftest(responses, targetpositions(:, 4));

P = randperm(length(targetpositions));
cutoff = 570; % between train & test

%% Linear regression for each of the 4 variables independently using top N channels
diffs = zeros([150 ,2]);
for i = 1:150 % Number of best channels used for each variable
    x1 = responses(P(1:cutoff), ranking1(1:i))\targetpositions(P(1:cutoff), 1);
    x2 = responses(P(1:cutoff), ranking2(1:i))\targetpositions(P(1:cutoff), 2);
    x3 = responses(P(1:cutoff), ranking3(1:i))\targetpositions(P(1:cutoff), 3);
    x4 = responses(P(1:cutoff), ranking4(1:i))\targetpositions(P(1:cutoff), 4);

    % Predict small test set
    preds = [responses(P(cutoff+1:end), ranking1(1:i))*x1...
        responses(P(cutoff+1:end), ranking2(1:i))*x2...
        responses(P(cutoff+1:end), ranking3(1:i))*x3...
        responses(P(cutoff+1:end), ranking4(1:i))*x4];

    % Mean error in test set
    diffs(i, :) = 3.32*[mean(rssq(preds(:, 1:2)-targetpositions(P(cutoff+1:end), 1:2),2))...
        mean(rssq(preds(:, 3:4)-targetpositions(P(cutoff+1:end), 3:4),2))];
end

% Convergence of front & back linear regression
plot(diffs);
title("Linear Regression Convergence");
ylabel("Error (mm)");
legend({"Front"; "Back"});
xlabel("Number of channels");

pause();

%% Visualise behaviours of test set
load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
for i = 1:30
    plot(outline(:, 1), outline(:,2), 'color', 'k');
    hold on
    scatter(preds(i, [1 3]), preds(i, [2 4]), 40, 'r', 'filled');
    scatter(targetpositions(P(cutoff+i), [1 3]), targetpositions(P(cutoff+i), [2 4]), 40, 'b', 'filled');
    line([preds(i, 1) targetpositions(P(cutoff+i), 1)], [preds(i, 2) targetpositions(P(cutoff+i), 2)]);
    line([preds(i, 3) targetpositions(P(cutoff+i), 3)], [preds(i, 4) targetpositions(P(cutoff+i), 4)]);
    3.32*rssq(preds(i, 1:2)-targetpositions(P(cutoff+i), 1:2),2)
    3.32*rssq(preds(i, 3:4)-targetpositions(P(cutoff+i), 3:4),2)
    title(sprintf("Test set %d", i));

    pause()
    clf
end