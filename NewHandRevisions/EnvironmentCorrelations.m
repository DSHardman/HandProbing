load("Data/Dataset6/CombinedSet6.mat");
load("Data/Dataset6/ExtractedExperimentalConditions.mat");

tranking = fsrftest(alldata(2:4:end, :), allconditions(1:2:end,2));
hranking = fsrftest(alldata(2:4:end, :), allconditions(1:2:end,1));

num_channels = 500;

figure();
heatmap(normalize(alldata(:, hranking(1:num_channels)), "range", [0 1]).',...
    "colormap", gray, 'XDisplayLabels',NaN*ones(3200,1),...
    'YDisplayLabels',NaN*ones(num_channels,1));
grid off
colorbar off
set(gcf, 'color', 'w', 'Position', [490   470   560   291]);

figure();
plot(linspace(0,7, length(conditions)), smooth(conditions(:,1), 100), 'linewidth', 2, 'color', 'b');
ylim([32 41]);
xlim([0 7]);
box off
set(gca, 'linewidth', 2, 'fontsize', 15);
set(gcf, 'color', 'w', 'Position', [490   214   560   206]);
ylabel("Humidity (%)");
xlabel("Time (h)");

return
figure();
subplot(4,1,1);
plot(conditiontimes, smooth(conditions(:,1), 800));
title("Actual Humidity");

subplot(4,1,2);
plot(alltimes(1:2:end), smooth(alldata(2:4:end, hranking(1)), 30));
title(sprintf("Recorded Humidity Channel: %d", hranking(1)));


subplot(4,1,3);
plot(conditiontimes, smooth(conditions(:,2), 800));
title("Actual Temperature");

subplot(4,1,4);
plot(alltimes(1:2:end), smooth(alldata(2:4:end, tranking(1)), 30));
title(sprintf("Recorded Temperature Channel: %d", tranking(1)));