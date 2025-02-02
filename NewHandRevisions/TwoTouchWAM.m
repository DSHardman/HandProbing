load("Data/SixBatches.mat");
% allsets = allsets(1:600, :);
% alltargets = alltargets(1:300, :);

% Give back touch locations a negative y position
load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
alltargets(:, 2) = alltargets(:, 2) - min(outline(:, 2));
alltargets(:, 4) = alltargets(:, 4) - min(outline(:, 2));
outline(:,2) = outline(:,2)-min(outline(:,2));
alltargets(:, 4) = -alltargets(:, 4);

% Extract responses
responses = zeros([length(alltargets), size(allsets, 2)]);
for i = 1:length(alltargets)
    responses(i, :) = allsets(2*i, :) - allsets(2*i-1, :);
end

%% Perform F-Test ranking & combine into single alternating ranking
ranking1 = fsrftest(responses, alltargets(:, 1));
ranking2 = fsrftest(responses, alltargets(:, 2));
ranking3 = fsrftest(responses, alltargets(:, 3));
ranking4 = fsrftest(responses, alltargets(:, 4));
combinedranking = zeros([4*10200, 1]);
for i = 1:10200
    combinedranking(4*i-3:4*i) = [ranking1(i); ranking2(i);...
                                    ranking3(i); ranking4(i)];
end
combinedranking = unique(combinedranking, 'stable');

%% WAM localization using top N channels: plot 10 random predictions from test set
% Prediction in pink, ground truth in red
figure();
[fronterror, backerror] = wamtesting(combinedranking(1:500), responses, alltargets, 1);
fronterror
backerror

return

% for i = 1:20
%     [error, sidepercent] = wamtesting(combinedranking(1:i*25), responses, alltargets, 0);
%     scatter(i*25, error, 50, 'k', 'filled');
%     hold on
% end

%% Create Error Map

% maximumnumber = 350;
% 
% maperrors = zeros([1080, 1]);
% ranking = franking(responses, targetpositions);
% 
% maperrors(1) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, 2:1080, 1);
% for i = 2:1079
%     if mod(i,10)==0
%         i
%     end
%     maperrors(i) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, [1:i-1 i+1:1080], i);
% end
% maperrors(1080) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, 1:1079, 1080);
% 
% % scatter(targetpositions(:,1), targetpositions(:,2), 20, maperrors, 'filled');
% interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), maperrors);
% [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
%                     linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
% value_interp = interpolant(xx,yy);
% value_interp = max(value_interp, 0); % Ignore any negative interpolated values
% % Remove points from outside hand
% for i = 1:size(xx,1)
%     for j = 1:size(xx,2)
%         if ~inpolygon(xx(i,j),abs(yy(i,j)), outline(:,1), outline(:,2))
%             value_interp(i,j) = nan;
%         end
%     end
% end
% contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
% colorbar();
% axis off
% set(gcf, 'color', 'w');

%% Plot sensitivity maps of top 10 configurations
% figure();
% for i = 1:10
%     subplot(2,5,i);
%     vals = abs(responses(:, ranking(i)));
%     interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
%     [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
%                         linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
%     value_interp = interpolant(xx,yy); 
%     value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
%     % Remove points from outside hand
%     for k = 1:size(xx,1)
%         for j = 1:size(xx,2)
%             if ~inpolygon(xx(k,j),abs(yy(k,j)), outline(:,1), outline(:,2))
%                 value_interp(k,j) = nan;
%             end
%         end
%     end
%     contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
%     axis off
%     colormap hot
% end

%% Produce WAM convergence graph
repetitions = 25;
maximumnumber = 500;

% my_colors;

[fronterrors, backerrors] = convergenceplot(responses, alltargets, repetitions,...
    maximumnumber, 'b', combinedranking);


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

    % traininds = [1:800 831:1080];
    % testinds = 801:830;

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

function [fronterrors, backerrors] = convergenceplot(responses, targetpositions, repetitions, maximumnumber, col, ranking)
    fronterrors = zeros([maximumnumber, repetitions]);
    backerrors = zeros([maximumnumber, repetitions]);
   
    for i = 100%1:maximumnumber
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

end