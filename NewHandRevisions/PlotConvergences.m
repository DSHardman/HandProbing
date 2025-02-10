subplot(1,2,1);
load("Data/Dataset6/FrontConvergences.mat");

plot(noranked, 'linewidth', 1, 'color', 'k', 'LineStyle', ':'); %1/255*[27 158 119]
hold on
plot(backranked, 'linewidth', 1, 'color', 'k'); % 1/255*[217 95 2]

plot(frontranked, 'linewidth', 2, 'color', 1/255*[27 158 119]);

legend({"No Ranking"; "Back Ranking"; "Front Ranking"}, 'fontsize', 15);
legend boxoff

box off
set(gca, 'fontsize', 15, 'linewidth', 2);
ylim([30 70]);
xlabel("Number of Channels");
ylabel("Prediction Error (mm)");
title("Front Predictions");

subplot(1,2,2);
load("Data/Dataset6/BackConvergences.mat");

plot(noranked, 'linewidth', 1, 'color', 'k', 'LineStyle', ':'); %1/255*[27 158 119]
hold on
plot(frontranked, 'linewidth', 1, 'color', 'k'); % 1/255*[217 95 2]

plot(backranked, 'linewidth', 2, 'color', 1/255*[27 158 119]);

legend({"No Ranking"; "Front Ranking"; "Back Ranking"}, 'fontsize', 15);
legend boxoff

box off
set(gca, 'fontsize', 15, 'linewidth', 2);
ylim([30 70]);
xlabel("Number of Channels");
ylabel("Prediction Error (mm)");
title("Back Predictions");

set(gcf, 'color', 'w', 'position', [14         370        1463         394]);