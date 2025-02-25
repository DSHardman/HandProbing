load("SavedData/betterdeltaresponses.mat");
load("SavedData/ExtractedPositions.mat");
load("ThomasBoltRankings/res_better_combs.mat");
responses = deltaresponses;

elecranking = [oppadinds; adadinds; oppoppinds];

% Top 2 plots: r & theta scatter with analytic 240 ranking
subplot(3,2,1);
pcascatter(responses(:, [elecranking; elecranking+3358/2]), positions, "r");
subplot(3,2,2);
pcascatter(responses(:, [elecranking; elecranking+3358/2]), positions, "theta");

% Middle 2 plots: r & theta scatter with PCA 240 ranking
[coeff,score,latent,tsquared,explained, mu] = pca(responses);
[~,pcaranking] = sort(coeff(:,1), 'descend');
subplot(3,2,3);
pcascatter(responses(:, pcaranking(1:240)), positions, "r");
subplot(3,2,4);
pcascatter(responses(:, pcaranking(1:240)), positions, "theta");

% Bottom 2 plots: r & theta scatter with Thomas's 240 ranking
subplot(3,2,5);
pcascatter(responses(:, combs2(1:240)), positions, "r");
subplot(3,2,6);
pcascatter(responses(:, combs2(1:240)), positions, "theta");

set(gcf, 'color', 'w', 'position', [475    76   532   795]);

function pcascatter(responses, positions, colormethod)
    [coeff,score,latent,tsquared,explained, mu] = pca(responses);
    
    axis3 = zeros([size(responses, 1),1]);
    
    for i = 1:size(responses, 1)
        [theta, r] = cart2pol(positions(i,1), positions(i,2));
        if colormethod == "theta"
            axis3(i) = theta;
        else
            axis3(i) = r; % color by radius as default
        end
    end

    scatter(score(:,1), score(:,2), 20, axis3, "filled");
    
    jet_wrap = vertcat(jet,flipud(jet));
    colormap(jet_wrap);
end