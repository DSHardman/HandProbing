load("../../TactileLocalization/HandOutline.mat");
load("../ExtractedSingleTouches.mat");

% for i=1:8
%     varName = sprintf('Aug%d.mat', i);
%     load(varName)
%     loadedVars1{i} = alldata(1:2:end,:);
%     loadedVars2{i} = alldata(2:2:end,:);
%     loadedVars3{i} = targetpositions;
% end
% 
% inp2= vertcat(loadedVars1{:});
% inp= vertcat(loadedVars2{:});
% targetpositions= vertcat(loadedVars3{:});

inp2 = alldata(1:2:end, :);
inp = alldata(2:2:end, :);

% new remove testers
filmedinputs = inp2(301:330,:) - inp(301:330,:);
filmedtargets = targetpositions(301:330, :);

inp = inp([1:300 331:end], :);
inp2 = inp2([1:300 331:end], :);


targetpositions = targetpositions([1:300 331:end], :);



% Define input and output sizes
%inputSize = 5570;
outputSize = 3;


% inpall=[inp2(:,1:2785) inp(:,1:2785)];
%inpall=[inp2(:,2785:end) inp(:,2785:end) ];
%inpall=[inp2(:,1:end)  ];

T = targetpositions(:,1:3)';




idx = fsrftest(inp2(:,:)-inp(:,:),T(2,:));
%inpall=[inp2(:,idx(1:20)) inp(:,idx(1:20)) ];

%inpall=[inp(:,idx(1:40))  ];

inpall = inp2(:,idx(1:1000))-inp(:,idx(1:1000));
filmedinputs = filmedinputs(:, idx(1:1000));

inputSize=size(inpall,2);
%inputSize=20;

numSamples = 1050; % was 800
X = inpall';  % Random input data
T = targetpositions(:,1:3)'; % Random target data

% Split the data into training and validation sets
trainRatio = 0.9;
valRatio = 0.1;
[trainInd, valInd, ~] = dividerand(numSamples, trainRatio, valRatio, 0);

% Define the deep network architecture with normalization layers
layers = [
    featureInputLayer(inputSize, 'Normalization', 'zscore')
    fullyConnectedLayer(20)
    reluLayer
    fullyConnectedLayer(50)
    tanhLayer
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(outputSize)
    regressionLayer];

% Define training options
options = trainingOptions('adam', ...
    'MaxEpochs', 1000, ...
    'InitialLearnRate', 1e-3, ...
     'Verbose', true, ...
    'ValidationData', {X(:, valInd)', T(:, valInd)'}, ...
    'ValidationFrequency', 50, ...
    'ValidationPatience', 20, ... % Number of epochs to wait for improvemen
    'Plots', 'training-progress', ...
    'MiniBatchSize', 64);

% Train the network
net = trainNetwork(X(:, trainInd)', T(:, trainInd)', layers, options);

% predictions = predict(net, X(:, valInd)');
% performance = mse(T(:, valInd), predictions);
% fprintf('Validation Performance: %f\n', performance);
% % Plot regression analysis
% figure;
% plotregression(T(:, valInd), predictions);
% title('Regression Analysis');


inpt2=alldata(1:2:end,:);
inpt=alldata(2:2:end,:);


%%%%%%
% inptest=[inpt2(:,idx(1:1000))-inpt(:,idx(1:1000))];
% X = inptest';  % Random input data
% predictionst = predict(net, X');
predictionst = predict(net, filmedinputs);

% Visualise test set
% for i=1:30
%      plot(outline(:,1),outline(:,2))
%      hold on
%      if predictionst(i,3)>0.5
%         cs=1;
%      else
%          cs=0;
%      end
%      scatter(predictionst(i,1),predictionst(i,2),20,cs,'filled');
%      hold on
%      scatter(filmedtargets(i,1),filmedtargets(i,2),20,'r','filled');
%      % w = waitforbuttonpress;
%      pause();
%      clf
% end

meanerror = 3.32*mean(rssq(predictionst(:, 1:2).' -...
    filmedtargets(:, 1:2).'))
