load("HemisphereEnvironment.mat");
conditions = conditions(15:end, :);
conditiontimes = conditiontimes(15:end);

subplot(2,1,1);
heatmap(normalize(readings(:, 1:1680), "range", [0 1]).', "colormap", gray); grid off
colorbar off
Ax = gca;
Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
title("Normalized RMS");
set(gca, 'fontsize', 15)

subplot(2,1,2);
yyaxis left
plot(hours(conditiontimes-conditiontimes(1)), conditions(:,1), 'linewidth', 2);
ylabel("Humidity (%)");

yyaxis right
plot(hours(conditiontimes-conditiontimes(1)), conditions(:,2), 'linewidth', 2);
ylabel("Temperature (^oC)");
ylim([17 25]);

xlim([0, hours(conditiontimes(end)-conditiontimes(1))]);
set(gca, 'fontsize', 15, 'linewidth', 2);
box off
xlabel("Time (h)");


set(gcf, 'position', [305   193   836   598], 'color', 'w');