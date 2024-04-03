load("Test1.mat");
rmsaverages = zeros([5, 870]);
for i = 1:2:1740
    reading = mean(alldata(1:end,i+[1:1984:1725211]).');
    rmsaverages(:, (i+1)/2) = reading*2.2/1024;
end

phaseaverages = zeros([5, 870]);
for i = 2:2:1740
    reading = mean(alldata(1:end,i+[1:1984:1725211]).');
    phaseaverages(:, i/2) = reading*2*pi/10;
end


subplot(2,1,1);
heatmap(rmsaverages.', "colormap", gray); grid off;
Ax = gca;
Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
colorbar off

subplot(2,1,2);
heatmap(phaseaverages.', "colormap", gray); grid off;
Ax = gca;
Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
colorbar off
