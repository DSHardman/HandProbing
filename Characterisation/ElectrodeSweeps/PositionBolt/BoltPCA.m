
% [coeff,score,latent,tsquared,explained, mu] = pca(deltaresponses(:,1:1679));

[coeff,score,latent,tsquared,explained, mu] = pca(deltaresponses);

axis3 = zeros([5000,1]);

for i = 1:5000
    [theta, r] = cart2pol(positions(i,1), positions(i,2));
    axis3(i) = round((theta+pi)/(pi/2));
    % axis3(i) = r;
end

%%

scatter(score(:,1), score(:,2), 20, axis3, "filled");

jet_wrap = vertcat(jet,flipud(jet));
colormap(jet_wrap);

hold on
Y = (data-mu)*coeff(:,1:2);
scatter(Y(:,1), Y(:,2), 20, "r");