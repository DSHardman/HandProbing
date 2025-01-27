load("Data/FourBatches.mat");

values = allsets(2:2:end, :)-allsets(1:2:end, :);
ranking1 = fsrftest(values, alltargets(:, 1));
ranking2 = fsrftest(values, alltargets(:, 2));
ranking3 = fsrftest(values, alltargets(:, 3));
ranking4 = fsrftest(values, alltargets(:, 4));

P = randperm(400);

% Linear regression for each of the 4 variables independently
diffs = zeros([150 ,2]);
for i = 1:150 % Number of best channels used for each variable
    x1 = values(P(1:350), ranking1(1:i))\alltargets(P(1:350), 1);
    x2 = values(P(1:350), ranking2(1:i))\alltargets(P(1:350), 2);
    x3 = values(P(1:350), ranking3(1:i))\alltargets(P(1:350), 3);
    x4 = values(P(1:350), ranking4(1:i))\alltargets(P(1:350), 4);

    % Predict small test set
    preds = [values(P(351:end), ranking1(1:i))*x1...
        values(P(351:end), ranking2(1:i))*x2...
        values(P(351:end), ranking3(1:i))*x3...
        values(P(351:end), ranking4(1:i))*x4];

    % Mean error in test set
    diffs(i, :) = 3.32*[mean(rssq(preds(:, 1:2)-alltargets(P(351:end), 1:2),2))...
        mean(rssq(preds(:, 3:4)-alltargets(P(351:end), 3:4),2))];
end

% Convergence of front & back linear regression
plot(diffs);

pause();

% Visualise behaviours of test set
for i = 1:50
    plot(positions(:, 1), positions(:,2), 'color', 'k');
    hold on
    scatter(preds(i, [1 3]), preds(i, [2 4]), 40, 'r', 'filled');
    scatter(alltargets(P(350+i), [1 3]), alltargets(P(350+i), [2 4]), 40, 'b', 'filled');
    line([preds(i, 1) alltargets(P(350+i), 1)], [preds(i, 2) alltargets(P(350+i), 2)]);
    line([preds(i, 3) alltargets(P(350+i), 3)], [preds(i, 4) alltargets(P(350+i), 4)]);
    3.32*rssq(preds(i, 1:2)-alltargets(P(350+i), 1:2),2)
    3.32*rssq(preds(i, 3:4)-alltargets(P(350+i), 3:4),2)

    pause()
    clf
end

%% Look at activation maps
for i = 1:50
    scatter(alltargets(:,1), alltargets(:,2), 40, values(:, ranking1(i)), 'filled');
    title(string(i));
    pause()
end