load("PrelimTouches.mat");
alldata = alldata(:, 1:end-4); % remove -1s

for i = 1:2:1740
    % reading = smooth(mean(alldata(1:end,i+[1:1984:1725211]).'), 10)*22/1024;
    reading = mean(alldata(1:end,i+[1:1984:1725211]).')*22/1024;
    plot(minutes(times(1:end)-times(1)), reading, 'color', 'k', 'LineStyle', '-', 'marker', 'none');
    hold on
end

ylim([-0.05 0.55]);
xlim([0 70]);
box off
set(gca, 'linewidth', 2, 'fontsize', 15);
set(gcf, 'position', [398   446   764   358], 'color', 'w');

%% Fingerprint

colors = (1/255)*[222 34 129];
figure();

[coeff,~,~,~,~,~] = pca(alldata(:, 1:2:end));
[~,ranking] = sort(abs(coeff(:,1)), 'descend');


heatmap(reshape(ranking, [870, 992]).',...
        'XDisplayLabels',NaN*ones(870,1), 'YDisplayLabels',NaN*ones(992,1));

grid off
colorbar off
map = [(colors(1):(1-colors(1))/1680:1).',...
    (colors(2):(1-colors(2))/1680:1).',...
    (colors(3):(1-colors(3))/1680:1).'];
colormap(map);

