load("Results.mat");

colors = (1/255)*[27 158 119; 217 95 2; 117 112 179; 231 41 138];

plot(1000*errors(1:150, 1), 'linewidth', 2, 'color', colors(1, :));
hold on
plot(1000*errors(1:150, 2), 'linewidth', 2, 'color', colors(2, :));
plot(1000*errors(1:150, 3), 'linewidth', 2, 'color', colors(3, :));
plot(1000*errors(1:150, 4), 'linewidth', 2, 'color', colors(4, :));

xlabel("Number of Combinations");
ylabel("Error (mm)");

set(gca, 'linewidth', 2, 'fontsize', 15);
box off
legend({"Analytic"; "PCA"; "F-Test"; "Environment"});
legend boxoff;
set(gcf, 'color', 'w', 'Position', [488   444   560   314]);

%% Scatter plot
subplot(2,2,1);
load("Top20Trained.mat");
scatter(testT(1,:), testT(2,:), 50, errors20, 'filled');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
axis square
axis off
colormap cool
colorbar; clim([0 0.035]);

subplot(2,2,2);
load("Top20PCA.mat");
scatter(testT(1,:), testT(2,:), 50, errors20pca, 'filled');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
axis square
axis off
colormap cool
colorbar; clim([0 0.035]);

subplot(2,2,3);
load("Top20Analytic.mat");
scatter(testT(1,:), testT(2,:), 50, errors20analytic, 'filled');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
axis square
axis off
colormap cool
colorbar; clim([0 0.035]);

subplot(2,2,4);
load("Random20Trained.mat");
scatter(testT(1,:), testT(2,:), 50, randomerrors, 'filled');
xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
axis square
axis off
colormap cool
colorbar; clim([0 0.035]);

set(gcf, 'position', [335          73        1014         807]);