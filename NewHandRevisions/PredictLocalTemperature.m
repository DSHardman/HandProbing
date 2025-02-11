%% Plot local temperature classification
% save for figure making
load("Data/Dataset6/CombinedSet6.mat");
[successes, score, YTest] = plotclasspredictions(alldata(1:4:end, :), temps, 1, 120);

figure();
for i = 1:4
    rectangle('position', [400+(i-1)*50 -0.1 25 1.25], 'facecolor', [0 0 1 0.2], 'edgecolor', 'none');
    text(403+(i-1)*50, 1.08, 'COLD','FontSize', 15, 'FontWeight','bold', 'Color', 'b');
    hold on
    rectangle('position', [425+(i-1)*50 -0.1 25 1.25], 'facecolor', [1 0 0 0.2], 'edgecolor', 'none');
    text(431+(i-1)*50, 1.08, 'HOT','FontSize', 15, 'FontWeight','bold', 'Color', 'r');
end

plot(401:600, 0.5*ones([200, 1]), 'color', 'k', 'LineStyle', '--', 'LineWidth', 1);
plot(401:600, score(:, 2), 'color', 1/255*[0 124 49], 'linewidth', 3);
plot(483:485, score(83:85, 2), 'color', 'r', 'linewidth', 4);
xlabel("Touch Number");
ylabel("Local Heating Prediction");
box off
ylim([-0.1 1.15])
set(gcf, 'color', 'w', 'position', [76   304   840   346]);
set(gca, 'linewidth', 2, 'fontsize', 15);

% v = VideoWriter("temps.avi");
% v.set('FrameRate', 20, 'Quality', 100);
% open(v);
% for i = 402:483
%     plot(401:i, score(1:i-400, 2), 'color', 1/255*[0 124 49], 'linewidth', 3);
%     writeVideo(v, getframe(gcf));
% end
% for i = 484:485
%     plot(483:i, score(83:i-400, 2), 'color', 'r', 'linewidth', 4);
%     writeVideo(v, getframe(gcf));
% end
% for i = 486:600
%     plot(485:i, score(85:i-400, 2), 'color', 1/255*[0 124 49], 'linewidth', 3);
%     writeVideo(v, getframe(gcf));
% end
% v.close();


%% Supervised clustering (discriminant analysis)

function [success, score, YTest] = plotclasspredictions(responses, patterns, predictindex, n)
    P = [401:600 1:400 700:800]; % take set in the middle of dataset1

    cutoff = 200; % how many to include in test set?

    % % % Fit classifier to all except cutoff random responses
    XTrain = responses(P(cutoff+1:end), :);
    YTrain = patterns(P(cutoff+1:end), predictindex);

    % Ranking
    idx = fsrftest(XTrain, YTrain);

    % Use only the top channels
    XTrain = XTrain(:, idx(1:n));

    % % Evaluate on 100 test set
    XTest = responses(P(1:cutoff), idx(1:n));
    YTest = patterns(P(1:cutoff), predictindex);

    discMdl = fitcdiscr(XTrain, YTrain, 'prior', 'empirical', 'DiscrimType','pseudolinear');
    
    [class, score] = predict(discMdl, XTest);

    success = length(find(class == YTest))/length(YTest);

end