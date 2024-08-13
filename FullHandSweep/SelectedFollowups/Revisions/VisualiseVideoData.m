clear frame

% load("FilmedTests/TFilmedDouble.mat");
% testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);
% frame = 9;

% load("FilmedTests/DamageFilm.mat");
% testresponses = alldata(2:end, :) - alldata(1, :);
% frame = 4;

% load("FilmedTests/TFilmedHeat.mat");
% testresponses = alldata(2:end, :) - alldata(2, :);
% frame = 3;

% load("FilmedTests/TFilmedMetal.mat");
% testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);
% frame = 3;

load("FilmedTests/TFilmedMiscTactile.mat");
testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);
frame = 4;

% load("FilmedTests/TFilmedPencil.mat");
% testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);
% frame = 3;

% load("FilmedTests/TFilmedSteam.mat");
% touchinds = [2 4 8 10 18 20 26 29 32 34 38 40];
% testresponses = zeros([length(touchinds), size(responses, 2)]);
% for i = 1:length(touchinds)
%     testresponses(i, :) = alldata(touchinds(i), :) - alldata(touchinds(i)-1, :);
% end

% load("FilmedTests/MultiTouch500.mat");
% testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);

% load("FilmedTests/WasherTests.mat");
% testresponses = alldata(2:2:end, :) - alldata(1:2:end, :);

%% Load in single touch training data

load("ExtractedSingleTouches.mat");

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

% testresponses = responses(301:330, :);
% responses = responses([1:300 331:end], :);
% testpositions = targetpositions(301:330, :);
% targetpositions = targetpositions([1:300 331:end], :);

% idxf = find(targetpositions(:,3)==0);
% targetpositions = targetpositions(idxf, :);
% responses = responses(idxf, :);

%% Perform F-Test ranking
ranking = franking(responses, targetpositions);

%% WAM localization using top N channels
figure();
if exist("frame", "var")
    wamvideos(ranking(1:800), responses, targetpositions, testresponses, frame);
    title(string(frame));
else
    for frame = 1:size(testresponses, 1)
        wamvideos(ranking(1:800), responses, targetpositions, testresponses, frame);
        title(string(frame));
        pause()
        clf
    end
end

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
function wamvideos(combinations, responses, targetpositions, testresponses, i)
    load("../TactileLocalization/HandOutline.mat");
    outline(:,2) = outline(:,2)-min(outline(:,2));

    [responses, C, S]= (normalize(responses)); 
    responses = tanh(responses);

    testresponses = tanh(normalize(testresponses, "center", C, "scale", S));


    % Sum activation maps
    sum = zeros([size(responses, 1), 1]);
    for j = 1:length(combinations)
        newsum = testresponses(i, combinations(j))*responses(:, combinations(j));
        if isempty(find(isnan(newsum), 1))
            sum = sum + newsum;
        end
    end

    % Plot prediction
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
    axis off
    set(gcf, 'color', 'w');

    colorbar
    % clim([0 50]);
end