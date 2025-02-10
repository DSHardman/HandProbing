% load("Data/Dataset2/CombinedSet2.mat");
load('Data/Dataset6/CombinedSet6.mat');

% Extract responses and remove those which were incorrectly measured by
% electronics
responses = alldata(4:4:end, :) - alldata(2:4:end, :);
% keepers = 1:800;
keepers = find(abs(mean(responses, 2) - mean(mean(responses, 2), 1))<1.5);
responses = responses(keepers, :);
targetpositions = targetpositions(keepers, :);

% Remove y offset from predictions
load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");

targetpositions(:, 2) = targetpositions(:, 2) - min(outline(:, 2));
targetpositions(:, 4) = targetpositions(:, 4) - min(outline(:, 2));
outline(:,2) = outline(:,2)-min(outline(:,2));
% targetpositions(:, 4) = -targetpositions(:, 4);


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
% % Plots results of small test set
num_configs=5000;
start = 401; % Index filming started
stop = 425; % Index filming ended
trainers = [1:length(find(keepers<start)) length(find(keepers<stop)):length(keepers)];
testers = length(find(keepers<=start)):length(find(keepers<=stop));

% figure();
% % First figure should give better front predictions
% % fronterror = wamtesting(frontranking(1:num_configs), responses, targetpositions, 1);
% fronterror = wamtesting(frontranking(1:num_configs), responses, targetpositions(:, 1:2), 1, trainers, testers);
% sgtitle("Using Front Ranking");
% set(gcf, 'color', 'w', 'position', [25         555        1456         304]);
% 
% 
% figure();
% % Second figure should give better back predictions
% % backerror = wamtesting(backranking(1:num_configs), responses, targetpositions, 1);
% backerror = wamtesting(backranking(1:num_configs), responses, targetpositions(:, 3:4), 1, trainers, testers);
% sgtitle("Using Back Ranking");
% set(gcf, 'color', 'w', 'position', [17         163        1456         304]);
% 
% fronterror
% backerror

%% Part 2: produce WAM convergence graph (takes a few minutes to run)
figure();
repetitions = 1;
maximumnumber = 5000;
% subplot(2,1,1);
backerrors = convergenceplot(responses, targetpositions(:, 3:4), repetitions,...
    maximumnumber, 'b', frontranking, trainers, testers);
save("frontrankingbackconvergence.mat", "backerrors");
% title("Using Front Ranking");

fronterrors = convergenceplot(responses, targetpositions(:, 1:2), repetitions,...
    maximumnumber, 'b', backranking, trainers, testers);
save("bakrankingfrontconvergence.mat", "fronterrors");

fronterrors = convergenceplot(responses, targetpositions(:, 1:2), repetitions,...
    maximumnumber, 'b', 1:10280, trainers, testers);
save("norankingfrontconvergence.mat", "fronterrors");

backerrors = convergenceplot(responses, targetpositions(:, 3:4), repetitions,...
    maximumnumber, 'b', 1:10280, trainers, testers);
save("norankingbackconvergence.mat", "backerrors");

% subplot(2,1,2);
% backerrors = convergenceplot(responses, targetpositions(:, 3:4), repetitions,...
%     maximumnumber, 'b', backranking, trainers, testers);
% save("backrankingconvergence.mat", "fronterrors", "backerrors");
% title("Using Back Ranking");

% sgtitle("WAM Convergence");

%% Implement WAM method from Hardman et al., Tactile Perception in Hydrogel-based Robotic Skins, 2023
function error = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
    load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
    outline(:,2) = outline(:,2)-min(outline(:,2));

    % % Normal
    responses = tanh(normalize(responses)); % Deal with outliers

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
    error = 0;

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

        % Average over n brightest pixels
        prediction = [0 0];

        for j = 1:n
            prediction = prediction + targetpositions(ind(j), 1:2);
        end
        prediction = prediction./n;

        % % Add localization error to running sum 
        error = error + rssq(abs(prediction)-abs(testpositions(i, 1:2)));

        % Plot prediction
        if figs && i >= 2
            subplot(2,12,i-1);
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
            % 
            %% Apply median filtering to image: only for visualisation (not current prediction)
            radius = 5/3.32; % In mm, with 3.32 correction factor
            includeindex = zeros([size(targetpositions, 1)]);
            for k = 1:size(targetpositions, 1)
                % Calculate front medians
                for j = 1:size(targetpositions, 1)
                    if rssq(targetpositions(k,1:2)-targetpositions(j,1:2)) < radius
                        includeindex(k, j) = 1;
                    end
                end
            end

            medianfrontsum = zeros(size(sum));
            for k = 1:size(targetpositions, 1)
                medianfrontsum(k, :) = median(sum(boolean(includeindex(k, :))));
            end
            sum = medianfrontsum;
            %% end median filtering
            
            scatter(targetpositions(:,1), targetpositions(:,2), 20, sum, 'filled');
            hold on
            plot(outline(:,1), outline(:,2), 'linewidth', 1, 'color', 'k');
            % Add ground truth and predicted touch locations
            scatter(testpositions(i, 1), testpositions(i, 2), 100, 'w', 'x', 'markeredgecolor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 5);
            scatter(prediction(1), prediction(2), 80, 'm', 'diamond', 'markeredgecolor', 'k', 'MarkerFaceColor', 'm', 'LineWidth', 3);
            

            axis off
            set(gcf, 'color', 'w');

            % For video overlay export:
            % set(gcf, 'position', [2454         394         134         166]);
            % % exportgraphics(gcf,"backtouch"+string(i)+".pdf", 'ContentType', 'vector');
            % exportgraphics(gcf,"fronttouch"+string(i)+".png", 'Resolution', 1000);
            % clf

            % title(sprintf("Error: %fmm", 3.32*rssq(abs(prediction)-abs(testpositions(i, 1:2)))));

        end
    end
    error = error/size(testresponses, 1); % calculate mean
    error = error*3.32; % convert to mm


end

%% Plot convergence graph
function errors = convergenceplot(responses, targetpositions, repetitions, maximumnumber, col, ranking, trainers, testers)
    errors = zeros([maximumnumber, repetitions]);
   
    for i = 1:maximumnumber
        i
        for j = 1:repetitions
            if nargin==8
                error = wamtesting(ranking(1:i), responses, targetpositions, 0, trainers, testers);
            elseif nargin == 6
                error = wamtesting(ranking(1:i), responses, targetpositions, 0);
            end
            errors(i, j) = error;
        end
    end

    plot(mean(errors(1:maximumnumber, :), 2), 'linewidth', 2, 'color', col);
    ylabel("Average Error (mm)");
    xlabel("Number of channels");
end