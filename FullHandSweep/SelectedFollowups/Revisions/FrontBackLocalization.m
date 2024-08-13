load("ExtractedSingleTouches.mat");
% alldata = alldata(1:1600, :);
% targetpositions = targetpositions(1:800, :);

% Give back touch locations a negative y position
load("../TactileLocalization/HandOutline.mat");
targetpositions(:, 2) = targetpositions(:, 2) - min(outline(:, 2));
outline(:,2) = outline(:,2)-min(outline(:,2));

idx = find(targetpositions(:,3) == 1);
targetpositions(idx, 2) = -targetpositions(idx, 2);

% Extract responses
responses = zeros([length(targetpositions), size(alldata, 2)]);
for i = 1:length(targetpositions)
    responses(i, :) = alldata(2*i, :) - alldata(2*i-1, :);
end

% idxf = find(targetpositions(:,3)==0);
% targetpositions = targetpositions(idxf, :);
% responses = responses(idxf, :);

%% Perform F-Test ranking
ranking = franking(responses, targetpositions);

%% WAM localization using top N channels: plot 10 random predictions from test set
% Prediction in pink, ground truth in red
figure();
[error, sidepercent] = wamtesting(ranking(1:500), responses, targetpositions, 1);
sgtitle("Mean error over entire test set: "+ string(error) + " mm, ");

% for n = 1:20
%     error = wamtesting(ranking(1:n*100), responses, targetpositions, 0);
%     scatter(n, error);
%     hold on
% end

% %% Plot sensitivity maps of top 10 configurations
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


%% F-Test Ranking
function ranking = franking(responses, targetpositions)
    combs2_x= fsrftest(responses, targetpositions(:, 1)); % x direction
    combs2_y= fsrftest(responses, targetpositions(:, 2)); % y direction

    % Combine directions
    combinedweights = zeros(size(combs2_x));
    for i = 1:length(responses)
        combinedweights(i) = find(combs2_x==i)+find(combs2_y==i);
    end
    [~, ranking] = sort(combinedweights, "ascend");
end


%% Implement WAM method from Hardman et al., Tactile Perception in Hydrogel-based Robotic Skins, 2023
function [error, sidepercent] = wamtesting(combinations, responses, targetpositions, figs)
    load("../TactileLocalization/HandOutline.mat");
    outline(:,2) = outline(:,2)-min(outline(:,2));

    % % Normal
    responses = tanh(normalize(responses)); % Deal with outliers

    % Generate test & train sets
    P = randperm(length(targetpositions));
    traininds = P(1:floor(0.9*length(targetpositions)));
    testinds = P(ceil(0.9*length(targetpositions)):end);
    % traininds = [1:800 831:1080];
    % testinds = 801:830;
    testresponses = responses(testinds, :);
    testpositions = targetpositions(testinds, :);
    responses = responses(traininds, :);
    targetpositions = targetpositions(traininds, :);

    % WAM using training set to predict test set
    error = 0;
    sidepercent = 0;
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

        % % prediction = [mean(targetpositions(ind(1:n), 1)),...
        % %                 mean(abs(targetpositions(ind(1:n), 2)))];
        % 
        % % Decide if prediction is front or back based on 49 brightest pixels
        % if length(find(targetpositions(ind(1:min(49, size(responses, 2))), 3)==1)) > 24
        %     % Predict back
        %     pred_side = 1;
        % else
        %     % Predict front
        %     pred_side = 0;
        % end
        % 
        % % Is the prediction correct?
        % if pred_side == testpositions(i, 3)
        %     sidepercent = sidepercent + 1;
        % end

        % Average over n brightest pixels on each side
        frontprediction = [0 0];
        backprediction = [0 0];
        frontcount = 0;
        backcount = 0;
        k = 1;
        while 1
            if targetpositions(ind(k), 3) == 0 && frontcount < n
                frontprediction = frontprediction + targetpositions(ind(k), 1:2);
                frontcount = frontcount + 1;
            elseif targetpositions(ind(k), 3) == 1 && backcount < n
                backprediction = backprediction + targetpositions(ind(k), 1:2);
                backcount = backcount + 1;
            end
            k = k + 1;
            if frontcount == n && backcount == n
                break
            end
        end
        frontprediction = frontprediction./n;
        backprediction = backprediction./n;

        

        % Add localization error to running sum 
        error = error + min([rssq(abs(frontprediction)-abs(testpositions(i, 1:2))),...
            rssq(abs(backprediction)-abs(testpositions(i, 1:2)))]);

        % Plot prediction
        if figs && i <= 10
            subplot(2,5,i);
            vals = sum;
            interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
            [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
                                linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
            value_interp = interpolant(xx,yy); 
            value_interp = max(value_interp, 0); % Don't allow extrapolation below zero

            % Remove points from outside hand
            for k = 1:size(xx,1)
                for j = 1:size(xx,2)
                    if ~inpolygon(xx(k,j),abs(yy(k,j)), outline(:,1), outline(:,2))
                        value_interp(k,j) = nan;
                    end
                end
            end
            contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
            
            hold on
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 30, 'r', 'filled');
            scatter(frontprediction(1), frontprediction(2), 30, 'm', 'filled');
            scatter(backprediction(1), backprediction(2), 30, 'm', 'filled');
            axis off
            set(gcf, 'color', 'w');

            % text(-113, 8, string(3.32*rssq(abs(prediction)-abs(testpositions(i, 1:2)))), 'color', 'w');
        end
    end
    error = error/size(testresponses, 1); % calculate mean
    error = error*3.32; % convert to mm
    sidepercent = 100*sidepercent/size(testresponses, 1);
end