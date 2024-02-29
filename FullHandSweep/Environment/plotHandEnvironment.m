% load("Hand32Environment.mat");
% alldataformat = alldataformat(:,5:end);

meanplots = zeros(236, 870);

yyaxis left
for i = 1:870
    reading = smooth(mean(alldataformat(2:end,(i-1)+[1:992:1725211]).'), 10)*22/1024;
    plot(seconds(times(3:end)-conditiontimes(1))/3600, reading-reading(1), 'color', 'k', 'LineStyle', '-', 'marker', 'none');
    meanplots(:, i) = reading-reading(1);
    hold on
end

ylim([-0.86 0.86]);

% plot(conditiontimes, conditions(:, 2)*5 - 105, 'color', 'r', 'LineWidth', 3);

yyaxis right
x = seconds(conditiontimes-conditiontimes(1));
f = fit(x.', conditions(:,2), 'poly2');

plot(x/3600, conditions(:, 2), 'color', 'r', 'LineWidth', 1);
plot(x/3600, f.p1*x.^2 + f.p2*x + f.p3, 'color', 'r', 'LineWidth', 3, 'LineStyle', '-', 'marker', 'none');

ylim([15 26]);

box off
xlim([0.2 19]);
set(gcf, 'color', 'w', 'position', [412   302   688   420]);

% plot(conditiontimes, 180-4*conditions(:, 1), 'color', 'b', 'LineWidth', 3);

% heatmap(normalize(meanplots, "range", [0 1]).', "colormap", gray); grid off