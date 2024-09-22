load("ExtractedSingleTouches.mat");
% alldata = alldata(1:1600, :);
% targetpositions = targetpositions(1:800, :);

% alldata = alldata(:, 5749:end);

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

% % Only data from a single side
% idxf = find(targetpositions(:,3)==1);
% targetpositions = targetpositions(idxf, :);
% responses = responses(idxf, :);

%% Perform F-Test ranking
ranking = franking(responses, targetpositions);

%% WAM localization using top N channels: plot 10 random predictions from test set
% Prediction in pink, ground truth in red
% figure();
[error, sidepercent] = wamtesting(ranking(1:500), responses, targetpositions, 1);
% sgtitle("Mean error over entire test set: "+ string(error) + " mm, ");

% for i = 1:20
%     [error, sidepercent] = wamtesting(ranking(1:i*25), responses, targetpositions, 0);
%     scatter(i*25, error, 50, 'k', 'filled');
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

%% Produce WAM convergence graph
% repetitions = 25;
% maximumnumber = 500;
% 
% my_colors;
% 
% % %OPOP
% % errorsopop = convergenceplot(responses(:, 2784*2+1:(2784+960)*2),...
% %     targetpositions, repetitions, maximumnumber, colors(1,:), 1);
% % 
% %OPAD
% errorsopad = convergenceplot(responses(:, (2784+960)*2+1:(2784+960+896)*2),...
%     targetpositions, repetitions, maximumnumber, colors(2,:), 1);
% % 
% % %ADAD
% % errorsadad = convergenceplot(responses(:, (2784+960+896)*2+1:2:(2784+960+896+928)*2),...
% %     targetpositions, repetitions, maximumnumber, colors(3,:), 1);
% % 
% % Full Selection
% errorsall = convergenceplot(responses, targetpositions, repetitions,...
%     maximumnumber, colors(4,:), 1);
% 
% % % Full Selection Unranked
% % errorsall = convergenceplot(responses(:, randperm(11140)), targetpositions, repetitions,...
% %     maximumnumber, colors(4,:), 0);
% 
% box off
% set(gca, 'linewidth', 2, 'fontsize', 15);
% xlabel("Number of Combinations");
% ylabel("Error (mm)");


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

    % % Generate test & train sets
    % P = randperm(length(targetpositions));
    % traininds = P(1:floor(0.9*length(targetpositions)));
    % testinds = P(ceil(0.9*length(targetpositions)):end);

    % Alternative: test set is 801-820 touches
    traininds = randperm(length(targetpositions));
    for i = 301:330
        ind = find(traininds==i);
        traininds = [traininds(1:ind-1) traininds(ind+1:end)];
    end
    testinds = 301:330;

    % multimodaltraininds = randperm(180);
    % testinds = multimodaltraininds(1:25);
    % 
    % for i = 1:length(testinds)
    %     ind = find(traininds==testinds(i));
    %     traininds = [traininds(1:ind-1) traininds(ind+1:end)];
    % end


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

        % Average over n brightest pixels on each side
        frontprediction = [0 0];
        backprediction = [0 0];
        frontcount = 0;
        frontsum = 0;
        backcount = 0;
        backsum = 0;
        k = 1;
        while 1
            if targetpositions(ind(k), 3) == 0 && frontcount < n
                frontprediction = frontprediction + targetpositions(ind(k), 1:2);
                frontcount = frontcount + 1;
                frontsum = frontsum + sum(ind(k));
            elseif targetpositions(ind(k), 3) == 1 && backcount < n
                backprediction = backprediction + targetpositions(ind(k), 1:2);
                backcount = backcount + 1;
                backsum = backsum + sum(ind(k));
            end
            k = k + 1;
            if frontcount == n && backcount == n
                break
            end

            % Deal with data from a single side
            if k > size(targetpositions, 1)
                break
            end
        end
        frontprediction = frontprediction./n;
        backprediction = backprediction./n;

        

        % Add localization error to running sum 
        error = error + min([rssq(abs(frontprediction)-abs(testpositions(i, 1:2))),...
            rssq(abs(backprediction)-abs(testpositions(i, 1:2)))]);

        % Plot prediction
        if figs && i == 18
            % subplot(2,5,i);
            % subplot(2,10,i);
            % subplot(1,7,i);
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
            % scatter(testpositions(i, 1), testpositions(i, 2), 30, 'r', 'filled');

            % if frontsum > backsum
            %     scatter(frontprediction(1), frontprediction(2), 30, 'm', 'filled');
            % else
            %     scatter(backprediction(1), backprediction(2), 30, 'm', 'filled');
            % end

            scatter(frontprediction(1), frontprediction(2), 30, 'm', 'filled');
            scatter(backprediction(1), backprediction(2), 30, 'm', 'filled');

            axis off
            set(gcf, 'color', 'w');

            % text(-113, 8, string(3.32*rssq(abs(prediction)-abs(testpositions(i, 1:2)))), 'color', 'w');
        end
    end
    error = error/size(testresponses, 1); % calculate mean
    error = error*3.32 % convert to mm
end

%% Plot convergence graph

function errors = convergenceplot(responses, targetpositions, repetitions, maximumnumber, col, ranked)
    errors = zeros([maximumnumber, repetitions]);
    
    % Ranked boolean determines whether F-Test order or just that given
    if ~ranked
        ranking = 1:length(targetpositions);
    else
        ranking = franking(responses, targetpositions);
    end
    
    for i = 1:maximumnumber
        i
        for j = 1:repetitions
            error = wamtesting(ranking(1:i), responses, targetpositions, 0);
            errors(i, j) = error;
        end
    end

    hold on
    plot(mean(errors.'), 'linewidth', 2, 'color', col);

end