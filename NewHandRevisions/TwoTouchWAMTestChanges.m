% load("Data/Dataset2/CombinedSet2.mat");
% load("Data/Dataset5/CombinedSet5Cleaned.mat");
load("Data/Dataset6/CombinedSet6.mat");
% responses = responses(1:800, :);
% targetpositions = targetpositions(1:800, :);

% responses = alldata(4:4:end, :);

% smoothempty = 10;
% responses = zeros([800, 10280]);
% for i = 1:smoothempty
%     reference = mean(alldata(2:4:i*4, :));
%     responses(i, :) = alldata(i*4, :) - reference;
% end
% for i = smoothempty+1:800
%     reference = mean(alldata(4*(i-smoothempty)-2:4:i*4, :));
%     responses(i, :) = alldata(i*4, :) - reference;
% end

% responses = alldata(3:4:end, :) - alldata(1:4:end, :);

% responses = responses(:, 1:2:end);

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

figure();
% First figure should give better front predictions
[fronterror, ~] = wamtesting(frontranking(1:500), responses, targetpositions, 1);
sgtitle("Using Front Ranking");


figure();
% Second figure should give better back predictions
[~, backerror] = wamtesting(backranking(1:2000), responses, targetpositions, 1);
sgtitle("Using Back Ranking");

fronterror
backerror
return
% return


figure();
% Third figure uses combined ranking
[error, sidepercent] = wamtesting(combinedranking(1:2000), responses, targetpositions, 1);
sgtitle("Using Combined Ranking");



%% Part 2: produce WAM convergence graph (takes a few minutes to run)
figure();
repetitions = 1;
maximumnumber = 1000;
subplot(2,1,1);
[fronterrors, ~] = convergenceplot(responses, targetpositions, repetitions,...
    maximumnumber, 'b', frontranking);
title("Using Front Ranking");

subplot(2,1,2);
[~, backerrors] = convergenceplot(responses, targetpositions, repetitions,...
    maximumnumber, 'b', backranking);
title("Using Back Ranking");

sgtitle("WAM Convergence");

%% Implement WAM method from Hardman et al., Tactile Perception in Hydrogel-based Robotic Skins, 2023
function [fronterror, backerror] = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
    load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
    outline(:,2) = outline(:,2)-min(outline(:,2));

    % % Normal
    responses = tanh(normalize(responses)); % Deal with outliers

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

            % vals = sum;
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
            % hold on

            % implement median filtering
            radius = 4;
            filteredfrontsum = zeros(size(sum));
            filteredbacksum = zeros(size(sum));
            for j = 1:length(sum)
                neighbours = [];
                for k = 1:length(sum)
                    if rssq(targetpositions(j, 1:2)-targetpositions(k, 1:2)) < radius
                        neighbours = [neighbours; sum(k)];
                    end
                end
                filteredfrontsum(j) = min(neighbours);

                neighbours = [];
                for k = 1:length(sum)
                    if rssq(targetpositions(j, 3:4)-targetpositions(k, 3:4)) < radius
                        neighbours = [neighbours; sum(k)];
                    end
                end
                filteredbacksum(j) = median(neighbours);
            end

            [~, ind] = sort(filteredfrontsum, 'descend');
            frontprediction = [0 0];
            for j = 1:n
                frontprediction = frontprediction + targetpositions(ind(j), 1:2);
            end
            frontprediction = frontprediction./n;

            [~, ind] = sort(filteredbacksum, 'descend');
            backprediction = [0 0];
            for j = 1:n
                backprediction = backprediction + targetpositions(ind(j), 3:4);
            end
            backprediction = backprediction./n;
            
            % [sortsum, inds] = sort(sum, 'ascend'); % ensure yellows are visible
            % topinds = inds(round(0.95*length(inds)):end);
            inds = 1:length(sum);
            scatter(targetpositions(inds,1), targetpositions(inds,2), 10, filteredfrontsum(inds), 'filled');
            % gscatter(targetpositions(:,1), targetpositions(:,2), sum>sortsum(round(0.95*length(inds))));
            hold on
            scatter(targetpositions(inds,3), targetpositions(inds,4), 10, filteredbacksum(inds), 'filled');
            % gscatter(targetpositions(:,3), targetpositions(:,4), sum>sortsum(round(0.95*length(inds))));            legend off
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 30, 'r', 'filled');
            scatter(testpositions(i, 3), testpositions(i, 4), 30, 'r', 'filled');
            % [~,C] = kmeans(targetpositions(topinds, 1:2), 2);
            % scatter(C(:, 1), C(:, 2), 30, 'g', 'filled');
            % T = cluster(linkage(targetpositions(topinds, 1:2)), 'MaxClust',3);
            % T
            scatter(frontprediction(1), frontprediction(2), 30, 'k', 'filled');
            % [~,C] = kmeans(targetpositions(topinds, 3:4), 2);
            % scatter(C(:, 1), C(:, 2), 30, 'g', 'filled');
            scatter(backprediction(1), backprediction(2), 30, 'k', 'filled');

            % %% Temporary: predict difference
            % vals = sum;
            % frontinterpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
            % backinterpolant = scatteredInterpolant(targetpositions(:,3), targetpositions(:,4), vals);
            % [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
            %                     linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
            % value_interp = frontinterpolant(xx,yy)-backinterpolant(xx,yy);
            % % value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
            % 
            % % Remove points from outside hand
            % for k = 1:size(xx,1)
            %     for j = 1:size(xx,2)
            %         if ~inpolygon(xx(k,j),abs(yy(k,j)), outline(:,1), outline(:,2))
            %             value_interp(k,j) = nan;
            %         end
            %     end
            % end
            % 
            % [~, in] = max(value_interp, [], 'all');
            % scatter(xx(in), yy(in), 50, 'k', 'filled');

            %%

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

function [fronterrors, backerrors] = convergenceplot(responses, targetpositions, repetitions, maximumnumber, col, ranking)
    fronterrors = zeros([maximumnumber, repetitions]);
    backerrors = zeros([maximumnumber, repetitions]);
   
    for i = 1:maximumnumber
        i
        for j = 1:repetitions
            [fronterror, backerror] = wamtesting(ranking(1:i), responses, targetpositions, 0);
            fronterrors(i, j) = fronterror;
            backerrors(i, j) = backerror;
        end
    end

    plot(mean(fronterrors.'), 'linewidth', 2, 'color', col);
    hold on
    plot(mean(backerrors.'), 'linewidth', 2, 'color', 'k');
    legend({"Front"; "Back"});
    ylabel("Average Error (mm)");
    xlabel("Number of channels");
end