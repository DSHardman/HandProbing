% Run first two sections of FrontBackLocalization

r = 2;

my_colors;

plot(outline(:,1), outline(:,2), 'color', 'k', 'LineWidth', 2);
axis off
set(gcf, 'color', 'w');
hold on
inds = find(targetpositions(:, 3)==0);
scatter(targetpositions(inds, 1), targetpositions(inds, 2));

% x = ginput(1);
load("HandCLocation.mat");
clf;
plot(outline(:,1), outline(:,2), 'color', 'k', 'LineWidth', 2);
axis off
set(gcf, 'color', 'w');
hold on
scatter(xpreds(:, 1), xpreds(:,2), 'color', 'k', 'marker', 'x');

N = 5;

repeatedresponses = [];
repeatedtimes = [];
hourtexts = [];

k = 1;
for i = 1:800%1080
    if targetpositions(i,3) == 0 && rssq(x - targetpositions(i, 1:2)) < r
        repeatedresponses = [repeatedresponses; responses(i, :)];
        repeatedtimes = [repeatedtimes; times(i*2)];
        hourtexts = [hourtexts; string(hours(times(i*2)-times(1))) + " hours"];
        scatter(targetpositions(i, 1), targetpositions(i,2), 30, colors(k, :), 'filled');
        k = k + 1;
        i
        if k == 5
            break
        end
    end
end

% 
% plot(repeatedtimes, repeatedresponses(:, ranking(1:N)));
% 
% figure();

% plot(repeatedresponses(:, 1:2:11136/2).');
figure();
for i = 1:k-1
    plot((22/1024)*repeatedresponses(i, ranking(1:100)).', 'linewidth', 2,...
        'color', colors(i, :), 'DisplayName', hourtexts(i));
    hold on
end
box off
set(gca, 'linewidth', 2', 'fontsize', 15);
legend('location', 's', 'Orientation', 'horizontal', 'Fontsize', 15);
legend boxoff
xlabel("Ranking");
ylabel("Response (mV)");
set(gcf, 'color', 'w', 'position', [2010         205        1147         420])


% for i = 1:5
%     subplot(1,5,i);
%     heatmap(reshape(repeatedresponses(i, 1:2:11136/2), [32 87]), "colormap", gray); grid off
% end
