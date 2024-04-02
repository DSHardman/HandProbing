modalities = [damages melting touch steelbolts pressrobot];

% PCA ranking of each - from RMS data only
rankings = zeros([1679, length(modalities)]);
for i = 1:length(modalities)
    [coeff,score,latent,tsquared,explained, mu] = pca(modalities(i).rms10k());
    [~,ranking] = sort(abs(coeff(:,1)), 'descend');
    rankings(:, i) = ranking;
end

% Combine all to determine the best 'average' combinations
combinedweights = zeros([1679, 1]);
for i = 1:1679
    for j = 1:length(modalities)
        combinedweights(i) = combinedweights(i) + find(rankings(:, j)==i);
    end
end
[~, generalranking] = sort(combinedweights, "ascend");

% % Plot first 20 best electrodes
% figure();
% for i = 1:20
%     subplot(4,5,i);
%     plotelectrodes(generalranking(i));
% end


% Determine uniqueness of specific modality
% i.e. the greatest gap between modality ranking and average ranking
n = 3; % look at the uniqueness of third entry in 'modalities' variable
uniqueness = zeros([1679, 1]);
for i = 1:1679
    uniqueness(i) = find(generalranking==i) - find(rankings(:, n)==i);
end
[~, uniqueranking] = sort(uniqueness, "descend");

% Plot first 20 best electrodes for unique
% figure();
% for i = 1:20
%     subplot(4,5,i);
%     plotelectrodes(uniqueranking(i));
% end

%heatmap(reshape([generalranking; NaN], [30, 56]).', 'XDisplayLabels',NaN*ones(30,1), 'YDisplayLabels',NaN*ones(56,1));

% channel = uniqueranking(1);
channel = generalranking(3);

responsemags = zeros([length(modalities), 1]);
% figure();
for i = 1:length(modalities)
    data = modalities(i).rms10k();
    responsemags(i) = abs(mean(data(30:38, channel))-mean(data(7:15, channel)));
    % plot(data(:,channel));
    % hold on
end
bar(responsemags);
set(gcf, 'position', [489   486   430   160], 'color', 'w');
box off

% legend({"damages"; "melting"; "touch"; "steelbolts"; "pressrobot"})