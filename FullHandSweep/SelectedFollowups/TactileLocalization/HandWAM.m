%% Logistics: load in data

% responses = zeros([100, size(alldata, 2)]);
% for i = 1:100
%     responses(i, :) = mean(alldata((i-1)*10+6:(i-1)*10+9, :)) -...
%         mean(alldata((i-1)*10+1:(i-1)*10+4, :));
% end

load("Dataset1/Touch500Data.mat");
load("HandOutline.mat");

responses = responses(1:399, :); % If disregarding final 100
targetpositions = targetpositions(1:399, :); % If disregarding final 100

% responses = responses(:, 11140/2 + 1:end); % If looking at a subset only
% responses = responses(:,2784*2+1:(2784+960)*2); % OPOP
% responses = responses(:,(2784+960)*2+1:(2784+960+896)*2); %OPAD
% responses = responses(:,(2784+960+896)*2+1:2:(2784+960+896+928)*2); %ADAD

%% Produce WAM convergence graph
repetitions = 25;
maximumnumber = 100;

my_colors;

%OPOP
errorsopop = convergenceplot(responses(:, 2784*2+1:(2784+960)*2),...
    targetpositions, repetitions, maximumnumber, colors(1,:), 1);

%OPAD
errorsopad = convergenceplot(responses(:, (2784+960)*2+1:(2784+960+896)*2),...
    targetpositions, repetitions, maximumnumber, colors(2,:), 1);

%ADAD
errorsadad = convergenceplot(responses(:, (2784+960+896)*2+1:2:(2784+960+896+928)*2),...
    targetpositions, repetitions, maximumnumber, colors(3,:), 1);

% Full Selection
errorsall = convergenceplot(responses, targetpositions, repetitions,...
    maximumnumber, colors(4,:), 1);

box off
set(gca, 'linewidth', 2, 'fontsize', 15);
xlabel("Number of Combinations");
ylabel("Error (mm)");

%% Produce WAM bar plot
figure();
Uerrorsopop = convergenceplot(responses(:, 2784*2+1:(2784+960)*2),...
    targetpositions, repetitions, maximumnumber, colors(1,:), 0);
Uerrorsopad = convergenceplot(responses(:, (2784+960)*2+1:(2784+960+896)*2),...
    targetpositions, repetitions, maximumnumber, colors(2,:), 0);
Uerrorsadad = convergenceplot(responses(:, (2784+960+896)*2+1:2:(2784+960+896+928)*2),...
    targetpositions, repetitions, maximumnumber, colors(3,:), 0);

figure();
bar([mean(Uerrorsopop(100, :)), mean(errorsopop(100, :)),...
    mean(Uerrorsopad(100, :)), mean(errorsopad(100, :)),...
    mean(Uerrorsadad(100, :)), mean(errorsadad(100, :)),...
    mean(errorsall(100, :))]);

%% Create Error Map

maperrors = zeros([399, 1]);
ranking = franking(responses, targetpositions);

maperrors(1) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, 2:399, 1);
for i = 2:398
    if mod(i,10)==0
        i
    end
    maperrors(i) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, [1:i-1 i+1:399], i);
end
maperrors(399) = wamtesting(ranking(1:maximumnumber), responses, targetpositions, 0, 1:398, 399);

% scatter(targetpositions(:,1), targetpositions(:,2), 20, maperrors, 'filled');
interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), maperrors);
[xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
                    linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
value_interp = interpolant(xx,yy);
value_interp = max(value_interp, 0); % Ignore any negative interpolated values
% Remove points from outside hand
for i = 1:size(xx,1)
    for j = 1:size(xx,2)
        if ~inpolygon(xx(i,j),yy(i,j), outline(:,1), outline(:,2))
            value_interp(i,j) = nan;
        end
    end
end
contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
colorbar();
axis off
set(gcf, 'color', 'w');

%% Plot sensitivity maps
for i = 1:100
    scatter(targetpositions(:, 1), targetpositions(:,2), 50, responses(:, ranking(i)), 'filled');
    % title(string(i));
    % colorbar
    % clim([0 0.5*max(abs(responses(:, i)))]);
    % vals = responses(:, ranking(i));
    % interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
    % [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
    %                     linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
    % value_interp = interpolant(xx,yy); 
    % % Remove points from outside hand
    % for i = 1:size(xx,1)
    %     for j = 1:size(xx,2)
    %         if ~inpolygon(xx(i,j),yy(i,j), outline(:,1), outline(:,2))
    %             value_interp(i,j) = nan;
    %         end
    %     end
    % end
    % contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
    axis off
    set(gcf, 'position', [871   531   272   284], 'color', 'w');
    pause();
end


%% WAM on filmed test-set data
% load("FilmedTestExtract.mat");
% wamtesting(ranking(1:50), responses, targetpositions, 1, testresponses, testpositions);
load("Dataset1/FilmIndices.mat");

ranking = franking(responses, targetpositions);
for i = 1:7
    wamtesting(ranking(1:100), responses, targetpositions, 1, nonfilmindices, filmindices(i));
    plot(outline(:,1), outline(:,2), 'color', 'k');
    print("video"+string(i)+".svg", "-dsvg");
    clf
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


%% WAM
function error = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
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
            axis off
            set(gcf, 'position', [871   531   272   284], 'color', 'w');
            pause();
            clf
        end
    end
    error = error/size(testresponses, 1); % calculate mean
    error = error*3.32; % convert to mm
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
        for j = 1:repetitions
            error = wamtesting(ranking(1:i), responses, targetpositions, 0);
            errors(i, j) = error;
        end
    end

    % STD polygon
    % x2 = [1:maximumnumber, maximumnumber:-1:1];
    % inBetween = [mean(errors.')-std(errors.'),...
    %     fliplr(mean(errors.')+std(errors.'))];
    % fill(x2, inBetween, col, 'linestyle', 'none', 'FaceAlpha', 0.5);
    
    % Mean line
    hold on
    plot(mean(errors.'), 'linewidth', 2, 'color', col);

end