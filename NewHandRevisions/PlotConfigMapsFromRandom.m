% load("Data/Dataset2/CombinedSet2.mat");
% load("Data/Dataset5/CombinedSet5Cleaned.mat");

%% Plot hand outline and choose area from user input
load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
plot(outline(:,1), outline(:,2)-43, 'color', 'k', 'linewidth', 2);
hold on
plot(outline(:,1), -outline(:,2)+43, 'color', 'k', 'linewidth', 2);
axis equal

title("Choose area of interest (2 clicks)");
centre = ginput(1);
side = centre(2) < 0;
hold on
scatter(centre(1), centre(2), 30, 'k', 'filled');
edge = ginput(1);

RoI = nsidedpoly(30, 'Center', centre, 'Radius', rssq(edge-centre));
hold on
plot(RoI);

%% Binary class: which locations are in this area?
binarytarget = zeros(length(targetpositions), 1);
for i = 1:length(targetpositions)
    if side
        if inpolygon(targetpositions(i, 3), -targetpositions(i, 4)+43, RoI.Vertices(:,1), RoI.Vertices(:,2))
            binarytarget(i) = 1;
        end
    else
        if inpolygon(targetpositions(i, 1), targetpositions(i, 2)-43, RoI.Vertices(:,1), RoI.Vertices(:,2))
            binarytarget(i) = 1;
        end
    end
end

%% Plot binary classes
if side
    gscatter(targetpositions(:,3), -targetpositions(:,4)+43, binarytarget);
    hold on
    scatter(targetpositions(:,1), targetpositions(:,2)-43, 30, 1/255*[52 115 186], 'filled');
else
    gscatter(targetpositions(:,1), targetpositions(:,2)-43, binarytarget);
    hold on
    scatter(targetpositions(:,3), -targetpositions(:,4)+43, 30, 1/255*[52 115 186], 'filled');
end
legend off
axis off
set(gcf, 'color', 'w');
axis equal

%% F-Test: Which configs tell us most about this binary class?
[ranking, scores] = fsrftest(responses, binarytarget);

%% Plot top 3 ranked configurations
figure();
for i = 1:3
    values = responses(:, ranking(i));
    values = tanh(normalize(values));

    subplot(1,3,i);
    % plotinterp(targetpositions(:, 1:2), values);
    scatter(targetpositions(:, 1), targetpositions(:,2)-43, 40, values, 'filled');
    hold on
    plot(outline(:,1), outline(:,2)-43, 'color', 'k', 'linewidth', 2);
    % plotinterp(targetpositions(:, 3:4), values);
    scatter(targetpositions(:, 3), -targetpositions(:,4)+43, 40, values, 'filled');
    hold on
    plot(outline(:,1), -outline(:,2)+43, 'color', 'k', 'linewidth', 2);
    plot(RoI, 'facecolor', 'none', 'linewidth', 2, 'edgecolor', [0.5 0.5 0.5]);
    caxis([-1 1]);
    axis off
    axis equal
end
set(gcf, 'color', 'w', 'Position', [20 86 1364 579]);


%% Unused function for more data: plot smooth, rather than scatter plot
function plotinterp(targetpositions, vals)
    load("../FullHandSweep/SelectedFollowups/TactileLocalization/HandOutline.mat");
    % outline(:,2) = outline(:,2)-min(outline(:,2));
    % vals = tanh(normalize(vals));

    interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
    [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
                        linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
    value_interp = interpolant(xx,yy); 
    % value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
    
    % Remove points from outside hand
    for k = 1:size(xx,1)
        for j = 1:size(xx,2)
            if ~inpolygon(xx(k,j),abs(yy(k,j)), outline(:,1), outline(:,2))
                value_interp(k,j) = nan;
            end
        end
    end
    contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
end