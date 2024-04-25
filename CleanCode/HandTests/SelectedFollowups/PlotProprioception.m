load("LowspeedProprioception.mat");

subplot(2,1,1);
heatmap(normalize(alldata(:, 5571:2:end), "range", [0 1]).', "colormap", gray); grid off
Ax = gca;
Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
colorbar off

subplot(2,1,2);
heatmap(normalize(alldata(:, 5572:2:end), "range", [0 1]).', "colormap", gray); grid off
Ax = gca;
Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
colorbar off

set(gcf, 'position', [475   433   560   338], 'color', 'w');