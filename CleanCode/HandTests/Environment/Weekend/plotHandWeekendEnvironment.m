load("Weekend.mat");

% load("Weekend2.mat"); load("Weekend2Conditions.mat");
alldata = alldata(:, 1:end-4); % remove -1s

% meanplots = zeros(1200, 870);

yyaxis left
% for i = 2:2:870
%     reading = smooth(mean(alldata(1:end,(i-1)+[1:992:1725211]).'), 10)*22/1024;
%     plot(seconds(times(1:end)-times(1))/3600, reading-reading(1), 'color', 'k', 'LineStyle', '-', 'marker', 'none');
%     % meanplots(:, i) = reading-reading(1);
%     hold on
% end

for i = 1:2:1740
    reading = smooth(mean(alldata(1:end,i+[1:1984:1725211]).'), 10)*22/1024;
    plot(seconds(times(1:end)-times(1))/3600, reading-reading(1), 'color', 'k', 'LineStyle', '-', 'marker', 'none');
    hold on
end

ylim([-0.8 1]);

yyaxis right

% Humidity Overlay
plot(seconds(times(1:end)-times(1))/3600, conditionsync(:, 1), 'color', 'r', 'LineWidth', 3);
ylim([18 60]);

% % Temperature Overlay
% plot(seconds(times(1:end)-times(1))/3600, conditionsync(:, 2), 'color', 'r', 'LineWidth', 3);
% set(gca, 'Ydir', 'reverse');
% ylim([7 25]);

% x = seconds(conditiontimessync-conditiontimesync(1));
% f = fit(x.', conditions(:,2), 'poly2');
% 
% plot(x/3600, conditions(:, 2), 'color', 'r', 'LineWidth', 1);
% plot(x/3600, f.p1*x.^2 + f.p2*x + f.p3, 'color', 'r', 'LineWidth', 3, 'LineStyle', '-', 'marker', 'none');
% 
% ylim([15 26]);

box off
% xlim([0.2 19]);
set(gcf, 'color', 'w', 'position', [412   302   688   420]);

% plot(conditiontimes, 180-4*conditions(:, 1), 'color', 'b', 'LineWidth', 3);

% heatmap(normalize(meanplots, "range", [0 1]).', "colormap", gray); grid off

%% Total ranking: RMS & Phase Simultaneously

% Correlation to humidity (absolute) - rank using this...
coefficients = zeros([size(alldata, 2), 1]);
for i = 1:size(alldata, 2)
    if mod(i,10000)==0
        i
    end
    R = corrcoef(conditionsync(:, 1), alldata(:,i));
    if ~isnan(R(1,2))
        coefficients(i) = abs(R(1,2));
    end
end

[~, ranking] = sort(coefficients, "descend");

%% Visualise Total Rankings

figure();
imshow(reshape(mod(ranking,2), [1984 870]).');

figure();
for i = 1:20
    subplot(4,5,i);
    plotelectrodes32(ceil(ranking(i)/2));
    hold on
    if mod(ranking(i),2)==0
        text(0,0,"PHASE");
    else
        text(0,0,"RMS");
    end
end

%% Seperate rankings to determine information-rich channels

combinedscore = zeros([size(ranking,1)/2, 1]);
for i = 1:size(ranking,1)/2
    if mod(i,10000)==0
        i
    end
    combinedscore(i) = find(ranking==2*i) + find(ranking==2*i-1);
end

[~, combinedranking] = sort(combinedscore, "ascend");


%% Visualise top 20 rankings
load("combinedranking.mat");
figure();
for i = 1:20
    subplot(4,5,i);
    plotelectrodes32(combinedranking(i));
end

figure();
viscircles([0 0], 1, 'color', 'k');
hold on
for i = 1:20
    plotelectrodes32fill(combinedranking(i));
end

%% Copy top combinations to clipboard for arduino
% Note arduino code subtracts 1 to account for different indexing system

data = "";
for i = 1:2784
    data = data + string(electrodes(combinedranking(i), 1)) + ", " + ...
        string(electrodes(combinedranking(i), 2)) + ", " + ...
        string(electrodes(combinedranking(i), 3)) + ", " + ...
        string(electrodes(combinedranking(i), 4)) + ", ";
end
data = char(data);
data = data(1:end-2); % Remove final comma

clipboard('copy', string(data));

%% Copy top non-combined combinations to clipboard for arduino
% Note arduino code subtracts 1 to account for different indexing system

% uniquerankings = mod(ranking-1, 32*31*30*29)+1;
uniquerankings = zeros([length(ranking), 1]);
for i = 1:length(ranking)
    uniquerankings(i) = ceil(ranking(i)/2);
end

uniquerankings = unique(uniquerankings,'stable');

data = "";
for i = 1:2784
    data = data + string(electrodes(uniquerankings(i), 1)) + ", " + ...
        string(electrodes(uniquerankings(i), 2)) + ", " + ...
        string(electrodes(uniquerankings(i), 3)) + ", " + ...
        string(electrodes(uniquerankings(i), 4)) + ", ";
end
data = char(data);
data = data(1:end-2); % Remove final comma

clipboard('copy', string(data));