% % warning('off','last')
testdata = [touch.rms10k() touch.phase10k()];

n = 1; % How many of the first PCA channels to average over
repetitions = 1; % Repetitions for each quantity

% quantity = [1:9 10:10:240 250:50:480 500:100:3300 3358];
quantity = [50:100:3358];

vals_pca = zeros([length(quantity), 1]);
vals_random = zeros([length(quantity), repetitions]);

numclusts = 7;


for i = 1:length(quantity)
    % quantity(i) % Print current location
    
    % PCA calculation
    coeff = pca(testdata);
    [~,ranking] = sort(mean(coeff(:,1:n), 2), 'descend');

    pcadata = testdata(:, ranking(1:quantity(i)));
    % [coeff,score,latent,tsquared,explained, mu] = pca(pcadata);
    % idx = kmeans(score(:, 1:quantity(i)), numclusts); % , "start", "uniform", "replicates", 500, "maxiter", 1000
    % s = silhouette(score(:, 1:quantity(i)), idx);
    idx = kmeans(pcadata, numclusts, "replicates", 5, "maxiter", 1000);
    s = silhouette(pcadata, idx);
    vals_pca(i) = mean(s);

    for j = 1:repetitions

        % Random Calculate
        ranking = randperm(3358);

        pcadata = testdata(:, ranking(1:quantity(i)));
        [coeff,score,latent,tsquared,explained, mu] = pca(pcadata);
        idx = kmeans(score(:, 1:2), numclusts);
        s = silhouette(score(:, 1:2), idx);
        vals_random(i, j) = mean(s);

    end
    % save("TradeoffPlot.mat","errorselecs1", "errorselecs2", "errorspca", "errorsrandom");
end

% Plot trade-off graph
plot(quantity, vals_pca, "color", "b");
hold on
plot(quantity, mean(vals_random, 2), "color", "k");

%% Old code: original plots
% 
% % warning('off','last')
% 
% testdata = touchsingle.rms10k();
% 
% numcombs = [50 100 200 300 400 500 600 1000 1500 1679];
% numreps = 1000;
% numclusts = 4;
% 
% sil_vals = zeros([numreps, length(numcombs)]);
% 
% for i = 1:length(numcombs)
%     i
%     for j = 1:numreps
%         inds = randperm(size(testdata, 2), numcombs(i));
%         pcadata = testdata(:, inds);
%         [coeff,score,latent,tsquared,explained, mu] = pca(pcadata);
%         idx = kmeans(score(:, 1:2),numclusts);
%         s = silhouette(score(:, 1:2), idx);
%         sil_vals(j,i) = mean(s);
%     end
% end
% 
% plot(numcombs, mean(sil_vals));