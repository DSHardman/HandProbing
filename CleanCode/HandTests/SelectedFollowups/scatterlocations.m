signal = deltas; %reading.selected;
% signal = signal - signal(:, 1);

[coeff,score,latent,tsquared,explained, mu] = pca(signal);

for i = 1:99
    scatter(score((i-1)*8+1:(i-1)*8+4, 1), score((i-1)*8+1:(i-1)*8+4, 2), 20, 'k', 'filled');
    hold on
    col = round(255*(targetpositions(i,2)-min(targetpositions(:,2)))/(max(targetpositions(:,2))-min(targetpositions(:,2)))) + 1;
    cmap = parula;
    scatter(score((i-1)*8+5:i*8, 1), score((i-1)*8+5:i*8, 2), 20, cmap(col, :), 'filled');
end

%%

rms = reading.rmsselected();
zrms = zeros([796, 2784]);
deltas = zeros([99, 2784]);
for i = 1:99
    zrms((i-1)*8+1:i*8, :) = [rms((i-1)*10+1:(i-1)*10+4, :); rms((i-1)*10+6:(i-1)*10+9, :)] - mean(rms((i-1)*10+1:(i-1)*10+3, :));
    deltas(i, :) = mean(rms((i-1)*10+6:(i-1)*10+9, :)) - mean(rms((i-1)*10+1:(i-1)*10+4, :));
end