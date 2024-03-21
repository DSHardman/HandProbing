%% Logistics: load in data

% responses = zeros([10, 11140]);
% for i = 1:10
%     responses(i, :) = mean(alldata((i-1)*10+6:(i-1)*10+9, :)) -...
%         mean(alldata((i-1)*10+1:(i-1)*10+4, :));
% end

load("Touch500Data.mat");
load("HandOutline.mat");

% responses = responses(1:399, :); % If disregarding final 100
% targetpositions = targetpositions(1:399, :); % If disregarding final 100

% responses = responses(:, 1:11140/2); % If looking at a subset only

%% Combined F-Test Ranking
combs2_x= fsrftest(responses, targetpositions(:, 1));
combs2_y= fsrftest(responses, targetpositions(:, 2));
combinedweights = zeros(size(combs2_x));
for i = 1:length(responses)
    combinedweights(i) = find(combs2_x==i)+find(combs2_y==i);
end
[~, ranking] = sort(combinedweights, "ascend");


%% Plot sensitivity maps
for i = 1:100
    % scatter(targetpositions(:, 1), targetpositions(:,2), 50, responses(:, ranking(i)), 'filled');
    % title(string(i));
    % colorbar
    % clim([0 0.5*max(abs(responses(:, i)))]);
    vals = responses(:, ranking(i));
    interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
    [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
                        linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
    value_interp = interpolant(xx,yy); 
    % Remove points from outside circle
    for i = 1:size(xx,1)
        for j = 1:size(xx,2)
            if ~inpolygon(xx(i,j),yy(i,j), outline(:,1), outline(:,2))
                value_interp(i,j) = nan;
            end
        end
    end
    contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
    pause();
end

%% Produce WAM convergence graph
repetitions = 5;
maximumnumber = 50;

errors = zeros([maximumnumber, repetitions]);

for i = 1:maximumnumber
    for j = 1:repetitions
        error = wamtesting(ranking(1:i), responses, targetpositions, 0);
        errors(i, j) = error;
    end
end
plot(mean(errors.'));


%% WAM on filmed test-set data
% load("FilmedTestExtract.mat");
% wamtesting(ranking(1:50), responses, targetpositions, 1, testresponses, testpositions);

%% WAM
function error = wamtesting(combinations, responses, targetpositions, figs, testresponses, testpositions)
    responses = tanh(normalize(responses)); % Deal with outliers

    % Generate test & train sets, if not explicityly input
    if nargin == 4
        P = randperm(length(targetpositions));
        traininds = P(1:floor(0.9*length(targetpositions)));
        testinds = P(ceil(0.9*length(targetpositions)):end);
        testresponses = responses(testinds, :);
        testpositions = targetpositions(testinds, :);
        responses = responses(traininds, :);
        targetpositions = targetpositions(traininds, :);
    end

    error = 0;

    % Loop through test set
    for i = 1:size(testresponses, 1)
        % Actual WAM process
        sum = zeros([size(responses, 1), 1]);
        for j = 1:length(combinations)
            newsum = testresponses(i, combinations(j))*responses(:, combinations(j));
            if isempty(find(isnan(newsum), 1))
                sum = sum + newsum;
            end
        end

        [~, ind] = sort(sum, 'descend');


        n = min(10, size(responses, 2));
        prediction = [mean(targetpositions(ind(1:n), 1)),...
                        mean(targetpositions(ind(1:n), 2))];


        error = error + rssq(prediction-testpositions(i,:));

        if figs
            scatter(targetpositions(:, 1), targetpositions(:, 2), 50, sum, 'filled');
            hold on
            scatter(testpositions(i, 1), testpositions(i, 2), 50, 'r', 'filled');
            scatter(prediction(1), prediction(2), 50, 'm', 'filled');
            pause();
            clf
        end
    end
    error = error/size(testresponses, 1); % calculate mean
    error = error*3.32; % convert to mm
end