% Heatmaps of correlations between all possible electrode configurations

rmss = HDamages.rms10k();

correlations = zeros(1679);

for i = 1:1679
    if mod(i,100)==0
        i
    end
    for j = 1:1679
        r = xcorr(rmss(:, i), rmss(:, j), "normalized");
        correlations(i,j) = max(r);
    end
end

heatmap(correlations); grid off; clim([0.99995 1]);
set(gcf, "color", "w");