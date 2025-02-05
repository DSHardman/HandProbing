%% Split random touch datasets into 10 areas over the hand
% Can then be used with PredictMultiTouchFromClasses script

% load("Data/Dataset2/CombinedSet2.mat");
load("Data/Dataset5/CombinedSet5Cleaned.mat");

% Show location of all areas
% load("Data/Split10Areas.mat");
for i = 1:10
    plot(areas(i));
    hold on
end
legend();

alltargets = zeros([length(targetpositions), 2]);
for i = 1:length(targetpositions)
    for j = 1:10
        if inpolygon(targetpositions(i, 1), targetpositions(i, 2)-43.5, areas(j).Vertices(:,1), areas(j).Vertices(:,2))
            alltargets(i, 1) = j;
            break
        end
    end

    for j = 1:10
        if inpolygon(targetpositions(i, 3), targetpositions(i, 4)-43.5, areas(j).Vertices(:,1), areas(j).Vertices(:,2))
            alltargets(i, 2) = j;
            break
        end
    end
end

binarytargets = zeros([length(targetpositions), 20]);
singletargets = zeros([length(targetpositions), 1]);
for i = 1:length(targetpositions)
    binarytargets(i, alltargets(i, 1)) = 1;
    binarytargets(i, alltargets(i, 2)+10) = 1;

    singletargets(i) = (alltargets(i,1)-1)*10 + alltargets(i,2);
end