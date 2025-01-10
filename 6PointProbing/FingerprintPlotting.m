load("channelresponses\Batch3.mat");

colors = (1/255)*[222 34 129];

for n = 1:6
    subplot(1,6,n);

    order = fsrftest(syncresponses(:, 1:1680), patterns(:, n));

    fingerprint = zeros([1680, 1]);
    for i = 1:1680
        fingerprint(i) = find(order==i);
    end

    heatmap(reshape(fingerprint, [30, 56]).', 'XDisplayLabels',NaN*ones(30,1),...
        'YDisplayLabels',NaN*ones(56,1));
    grid off
    colorbar off
    map = [(colors(1):(1-colors(1))/1680:1).',...
        (colors(2):(1-colors(2))/1680:1).',...
        (colors(3):(1-colors(3))/1680:1).'];
    colormap(map);
end

set(gcf, 'position', [85 540 1322 218]);

%% Plot electrode configurations

figure();
for n = 1:6
    subplot(1,6,n);
    order = fsrftest(syncresponses(:, 1:1680), patterns(:, n));

    plotelectrodes6point(order(1));
    axis off
end

set(gcf, 'color', 'w', 'position', [154 528 1182 230]);