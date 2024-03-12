% Bolt positions and betterdeltaresponses loaded from file
load("ExtractedPositions.mat");
load("betterdeltaresponses.mat");

% PCA and analytic rankings loaded from file
load("rankings.mat");

% F-Test Ranking
combs2_x= fsrftest(deltaresponses,positions(:, 1));
[~, rankingcombs_x] = sort(combs2_x,'descend');
combs2_y= fsrftest(deltaresponses,positions(:, 2));
[~, rankingcombs_y] = sort(combs2_y,'descend');
combinedweights = zeros(size(combs2_x));
for i = 1:3358
    combinedweights(i) = find(rankingcombs_x==i)+find(rankingcombs_y==i);
end
[~, combsranking] = sort(combinedweights, "ascend");

% Where should testing occur?
quantities = [1:500];
errors = zeros([length(quantities), 3]); % In order analytic, PCA, F-Test


for j=1:length(quantities)
    P = quantities(j)
    Y = positions';

    % Analytic
    X=deltaresponses(:,analytic(1:P))';
    net = fitnet(80);
    [net,tr] = train(net,X,Y,'useParallel','yes');
    testX = X(:,tr.testInd);
    testT = Y(:,tr.testInd);
    testY = net(testX);
    errors(j, 1) = mean(rssq(testT-testY));

    % PCA
    X=deltaresponses(:,pca(1:P))';
    net = fitnet(80);
    [net,tr] = train(net,X,Y,'useParallel','yes');
    testX = X(:,tr.testInd);
    testT = Y(:,tr.testInd);
    testY = net(testX);
    errors(j, 2) = mean(rssq(testT-testY));

    % F-Test
    X=deltaresponses(:,combsranking(1:P))';
    net = fitnet(80);
    [net,tr] = train(net,X,Y,'useParallel','yes');
    testX = X(:,tr.testInd);
    testT = Y(:,tr.testInd);
    testY = net(testX);
    errors(j, 3) = mean(rssq(testT-testY));

    % Save progress
    save("MLData.mat", "errors");

end