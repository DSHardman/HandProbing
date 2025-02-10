% load("Data/Dataset2/CombinedSet2.mat");
load('Data/Dataset6/CombinedSet6.mat');

% Extract responses and remove those which were incorrectly measured by
% electronics
responses = alldata(4:4:end, :) - alldata(2:4:end, :);
% keepers = 1:800;
keepers = find(abs(mean(responses, 2) - mean(mean(responses, 2), 1))<1.5);
responses = responses(keepers, :);
targetpositions = targetpositions(keepers, :);

% Give back touch locations a negative y position
load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");

targetpositions(:, 2) = targetpositions(:, 2) - min(outline(:, 2));
targetpositions(:, 4) = targetpositions(:, 4) - min(outline(:, 2));
outline(:,2) = outline(:,2)-min(outline(:,2));
targetpositions(:, 4) = -targetpositions(:, 4);


%% Perform F-Test ranking for x & y on front & back
 ranking1 = fsrftest(responses, targetpositions(:, 1));
 ranking2 = fsrftest(responses, targetpositions(:, 2));
 ranking3 = fsrftest(responses, targetpositions(:, 3));
 ranking4 = fsrftest(responses, targetpositions(:, 4));

% ranking1 = fsrmrmr(responses, targetpositions(:, 1));
% ranking2 = fsrmrmr(responses, targetpositions(:, 2));
% ranking3 = fsrmrmr(responses, targetpositions(:, 3));
% ranking4 = fsrmrmr(responses, targetpositions(:, 4));

% ranking1 = randperm(length(responses));
% ranking2 = randperm(length(responses));
% ranking3 = randperm(length(responses));
% ranking4 = randperm(length(responses));

%% Combine into global rankings
combinedranking = zeros([4*size(responses, 2), 1]);
frontranking = zeros([2*size(responses, 2), 1]);
backranking = zeros([2*size(responses, 2), 1]);
for i = 1:size(responses, 2)
    combinedranking(4*i-3:4*i) = [ranking1(i); ranking2(i);...
                                    ranking3(i); ranking4(i)];
    frontranking(2*i-1:2*i) = [ranking1(i); ranking2(i)];
    backranking(2*i-1:2*i) = [ranking3(i); ranking4(i)];
end
combinedranking = unique(combinedranking, 'stable');
frontranking = unique(frontranking, 'stable');
backranking = unique(backranking, 'stable');

differences = zeros([size(responses, 2), 1]);
for i = 1:size(responses, 2)
    differences(i) = find(backranking==i) - find(frontranking==i);
end
[~, backunique] = sort(differences, 'ascend');
[~, frontunique] = sort(differences, 'descend');

%% WAM localization using top N channels
% Plots results of small test set
num_configs=5000;
start = 401; % Index filming started
stop = 425; % Index filming ended
trainers = [1:length(find(keepers<start)) length(find(keepers<stop)):length(keepers)];
testers = length(find(keepers<=start)):length(find(keepers<=stop));

figure();
% First figure should give better front predictions
% [fronterror, ~] = wamtesting(frontranking(1:num_configs), responses, targetpositions, 1);
[fronterror, ~] = wamtesting(frontranking(1:num_configs), responses, targetpositions, 1, trainers(randperm(length(trainers))), testers(randperm(length(testers))));
sgtitle("Using Front Ranking");

figure();
% Second figure should give better back predictions
% [~, backerror] = wamtesting(backranking(1:num_configs), responses, targetpositions, 1);
[~, backerror] = wamtesting(backranking(1:num_configs), responses, targetpositions, 1, trainers(randperm(length(trainers))), testers(randperm(length(testers))));
sgtitle("Using Back Ranking");

fronterror
backerror
return
% figure();
% % Third figure uses combined ranking
% [fronterror, backerror] = wamtesting(combinedranking(1:num_configs), responses, targetpositions, 1);
% sgtitle("Using Combined Ranking");

%% Part 2: produce WAM convergence graph (takes a few minutes to run)
figure();
repetitions = 1;
maximumnumber = 7000;
subplot(2,1,1);
[fronterrors, backerrors] = convergenceplot(responses, targetpositions, repetitions,...
    maximumnumber, 'b', frontranking, trainers, testers);
save("frontrankingconvergence.mat", fronterrors, backerrors);
title("Using Front Ranking");

subplot(2,1,2);
[fronterrors, backerrors] = convergenceplot(responses, targetpositions, repetitions,...
    maximumnumber, 'b', backranking, trainers, testers);
save("backrankingconvergence.mat", fronterrors, backerrors);
title("Using Back Ranking");

sgtitle("WAM Convergence");

%% Implement WAM method from Hardman et al., Tactile Perception in Hydrogel-based Robotic Skins, 2023
function [fronterror, backerror] = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
    load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
    outline(:,2) = outline(:,2)-min(outline(:,2));

    % % Normal
    responses = tanh(normalize(responses)); % Deal with outliers
    %responses = (normalize(responses)); % Deal with outlier

    % Generate test & train sets, if not explicitly input
    if nargin == 4
        P = randperm(length(targetpositions));
        traininds = P(1:floor(0.9*length(targetpositions)));
        testinds = P(ceil(0.9*length(targetpositions)):end);
    end

    testresponses = responses(testinds, :);
    testpositions = targetpositions(testinds, :);
    responses = responses(traininds, :);
    targetpositions = targetpositions(traininds, :);

    % responses = tanh(normalize(responses)); % Deal with outliers

    %% Apply median filtering to responses - no changes outside of here

    % medianfrontresponses = zeros(size(responses));
    % radius = 5/3.32; % In mm, with 3.32 correction factor
    % for i = 1:size(targetpositions, 1)
    %     % Calculate front medians
    %     includeindex = zeros([size(targetpositions, 1), 1]);
    %     for j = 1:size(targetpositions, 1)
    %         if rssq(targetpositions(i,1:2)-targetpositions(j,1:2)) < radius
    %             includeindex(j) = 1;
    %         end
    %     end
    %     medianfrontresponses(i, :) = median(responses(boolean(includeindex), :));
    % end
    % responses = medianfrontresponses;
    % % responses = tanh(normalize(responses)); % Deal with outliers

    % end median filtering - no changes outside of here

    % %% Apply median filtering to sum pt 1- no changes outside of here
    % 
    % radius = 5/3.32; % In mm, with 3.32 correction factor
    % includeindex = zeros([size(targetpositions, 1)]);
    % for k = 1:size(targetpositions, 1)
    %     % Calculate front medians
    %     for j = 1:size(targetpositions, 1)
    %         if rssq(targetpositions(k,1:2)-targetpositions(j,1:2)) < radius
    %             includeindex(k, j) = 1;
    %         end
    %     end
    % end
    % 
    % %% end median filtering pt 1- no changes outside of here

    % WAM using training set to predict test set
    fronterror = 0;
    backerror = 0;

    % Loop through test set
    for i = 1:size(testresponses, 1)

        % Sum activation maps
        sum = zeros([size(responses, 1), 1]);
        for j = 1:length(combinations)
            newsum = testresponses(i, combinations(j))*responses(:, combinations(j));
            if isempty(find(isnan(newsum), 1))
                sum = sum + newsum;
            end
        end

        % % median filtering to sum pt 2
        % medianfrontsum = zeros(size(sum));
        % for k = 1:size(targetpositions, 1)
        %     medianfrontsum(k, :) = median(sum(boolean(includeindex(k, :))));
        % end
        % sum = medianfrontsum;
        % % end pt 2

        % Prediction is the average location of the n brightest pixels
        % n can be changed - 8 has worked best in the past
        [~, ind] = sort(sum, 'descend');
        n = min(8, size(responses, 2));

        % Average over n brightest pixels on each side
        frontprediction = [0 0];
        backprediction = [0 0];

        for j = 1:n
            frontprediction = frontprediction + targetpositions(ind(j), 1:2);
            backprediction = backprediction + targetpositions(ind(j), 3:4);
        end
        frontprediction = frontprediction./n;
        backprediction = backprediction./n;

        % % Add localization error to running sum 
        fronterror = fronterror + rssq(abs(frontprediction)-abs(testpositions(i, 1:2)));
        backerror = backerror + rssq(abs(backprediction)-abs(testpositions(i, 3:4)));

        % Plot prediction
        if figs && i <= 10
            subplot(2,5,i);
            vals = sum;
            % interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
            % [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
            %                     linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
            % value_interp = interpolant(xx,yy); 
            % value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
            % 
            % % Remove points from outside hand
            % for k = 1:size(xx,1)
            %     for j = 1:size(xx,2)
            %         if ~inpolygon(xx(k,j),abs(yy(k,j)), outline(:,1), outline(:,2))
            %             value_interp(k,j) = nan;
            %         end
            %     end
            % end
            % contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
            
            scatter(targetpositions(:,1), targetpositions(:,2), 20, sum, 'filled');
            hold on
            scatter(targetpositions(:,3), targetpositions(:,4), 20, sum, 'filled');
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 30, 'r', 'filled');
            scatter(testpositions(i, 3), testpositions(i, 4), 30, 'r', 'filled');
            scatter(frontprediction(1), frontprediction(2), 30, 'm', 'filled');
            scatter(backprediction(1), backprediction(2), 30, 'm', 'filled');

            axis off
            set(gcf, 'color', 'w');

            title(sprintf("Front: %fmm, Back:%fmm", 3.32*rssq(abs(frontprediction)-abs(testpositions(i, 1:2))),...
                3.32*rssq(abs(backprediction)-abs(testpositions(i, 3:4)))));

            % text(-113, 8, string(3.32*rssq(abs(prediction)-abs(testpositions(i, 1:2)))), 'color', 'w');
        end
    end
    fronterror = fronterror/size(testresponses, 1); % calculate mean
    fronterror = fronterror*3.32; % convert to mm

    backerror = backerror/size(testresponses, 1); % calculate mean
    backerror = backerror*3.32; % convert to mm

end

%% Plot convergence graph

function [fronterrors, backerrors] = convergenceplot(responses, targetpositions, repetitions, maximumnumber, col, ranking, trainers, testers)
    fronterrors = zeros([maximumnumber, repetitions]);
    backerrors = zeros([maximumnumber, repetitions]);

   
    for i = 1:maximumnumber
        i
        for j = 1:repetitions
            if nargin==8
                [fronterror, backerror] = wamtesting(ranking(1:i), responses, targetpositions, 0, trainers, testers);
            elseif nargin == 6
                [fronterror, backerror] = wamtesting(ranking(1:i), responses, targetpositions, 0);
            end
            fronterrors(i, j) = fronterror;
            backerrors(i, j) = backerror;
        end
    end

    plot(mean(fronterrors(1:maximumnumber, :), 2), 'linewidth', 2, 'color', col);
    hold on
    plot(mean(backerrors(1:maximumnumber, :), 2), 'linewidth', 2, 'color', 'k');
    legend({"Front"; "Back"});
    ylabel("Average Error (mm)");
    xlabel("Number of channels");
end