load("electrodes.mat");
load("PositionBolt/MLTests/rankings.mat");
electrodes = [electrodes; electrodes];
n = 150; % How many of the best ranked to look at?


%% Gap Distributions
figure();
subplot(4,1,1); Igapdistribution(analytic, n, electrodes);
title("Analytic");
subplot(4,1,2); Igapdistribution(pca, n, electrodes);
title("PCA");
subplot(4,1,3); Igapdistribution(combsranking, n, electrodes);
title("F-Test");
subplot(4,1,4); Igapdistribution(envranking, n, electrodes);
title("Environmental");
sgtitle("I Gap Distribution");

figure();
subplot(4,1,1); Vgapdistribution(analytic, n, electrodes);
title("Analytic");
subplot(4,1,2); Vgapdistribution(pca, n, electrodes);
title("PCA");
subplot(4,1,3); Vgapdistribution(combsranking, n, electrodes);
title("F-Test");
subplot(4,1,4); Vgapdistribution(envranking, n, electrodes);
title("Environmental");
sgtitle("V Gap Distribution");

%% Electrode Distributions: figure version
figure();
analyticbar = totalelectrodedistribution(analytic, n, electrodes);
pcabar = totalelectrodedistribution(pca, n, electrodes);
combsbar = totalelectrodedistribution(combsranking, n, electrodes);
clf
bar([analyticbar pcabar combsbar].');

%% Electrode Distributions: all
figure();
subplot(4,1,1); totalelectrodedistribution(analytic, n, electrodes);
title("Analytic");
subplot(4,1,2); totalelectrodedistribution(pca, n, electrodes);
title("PCA");
subplot(4,1,3); totalelectrodedistribution(combsranking, n, electrodes);
title("F-Test");
subplot(4,1,4); totalelectrodedistribution(envranking, n, electrodes);
title("Environmental");
sgtitle("Total Electrode Distributions");

figure();
subplot(4,1,1); Ielectrodedistribution(analytic, n, electrodes);
title("Analytic");
subplot(4,1,2); Ielectrodedistribution(pca, n, electrodes);
title("PCA");
subplot(4,1,3); Ielectrodedistribution(combsranking, n, electrodes);
title("F-Test");
subplot(4,1,4); Ielectrodedistribution(envranking, n, electrodes);
title("Environmental");
sgtitle("I Electrode Distributions");

figure();
subplot(4,1,1); Velectrodedistribution(analytic, n, electrodes);
title("Analytic");
subplot(4,1,2); Velectrodedistribution(pca, n, electrodes);
title("PCA");
subplot(4,1,3); Velectrodedistribution(combsranking, n, electrodes);
title("F-Test");
subplot(4,1,4); Velectrodedistribution(envranking, n, electrodes);
title("Environmental");
sgtitle("V Electrode Distributions");

%% Circular Distributions
figure();
subplot(5,1,1); circulardistributions(randperm(3358), n, electrodes);
title("Random");
subplot(5,1,2); circulardistributions(analytic, n, electrodes);
title("Analytic");
subplot(5,1,3); circulardistributions(pca, n, electrodes);
title("PCA");
subplot(5,1,4); circulardistributions(combsranking, n, electrodes);
title("F-Test");
subplot(5,1,5); circulardistributions(envranking, n, electrodes);
title("Environmental");
sgtitle("Circular Pattern Distributions");



% %% Rolling plot
% for i = 1:8
%     rollingvalue = zeros([3358-100, 1]);
%     for j = 100:3358
%         n = 0;
%         for k = 1:100
%             type = combinationtype(electrodes(testranking(j-100+k), :));
%             if type == i
%                 n = n + 1;
%             end
%         end
%         rollingvalue(j-99) = n;
%     end
%     plot(rollingvalue);
%     hold on
% end

%% I Gap Distribution

function Igapdistribution(testranking, n, electrodes)
    barvals = zeros([4, 1]);
    for i = 1:n
        elec = electrodes(testranking(i), 1:2);
        gap = max(elec) - min(elec);
        if gap > 4
            gap = 8 - gap;
        end
        barvals(gap) = barvals(gap) + 1;
    end
    bar(barvals);
end

%% V Gap Distribution

function Vgapdistribution(testranking, n, electrodes)
    barvals = zeros([4, 1]);
    for i = 1:n
        elec = electrodes(testranking(i), 3:4);
        gap = max(elec) - min(elec);
        if gap > 4
            gap = 8 - gap;
        end
        barvals(gap) = barvals(gap) + 1;
    end
    bar(barvals);
end

%% Inclusion distribution

function barvals = totalelectrodedistribution(testranking, n, electrodes)
    barvals = zeros([8, 1]);
    for i = 1:n
        for j = 1:8
            if any(electrodes(testranking(i), 3:4)==j)
                barvals(j) = barvals(j) + 1;
            end
        end
    end
    bar(barvals);
end

function Ielectrodedistribution(testranking, n, electrodes)
    barvals = zeros([8, 1]);
    for i = 1:n
        for j = 1:8
            if any(electrodes(testranking(i), 1:2)==j)
                barvals(j) = barvals(j) + 1;
            end
        end
    end
    bar(barvals);
end

function Velectrodedistribution(testranking, n, electrodes)   
    barvals = zeros([8, 1]);
    for i = 1:n
        for j = 1:8
            if any(electrodes(testranking(i), 3:4)==j)
                barvals(j) = barvals(j) + 1;
            end
        end
    end
    bar(barvals);
end

%% Circular Combination Distributions

function circulardistributions(testranking, n, electrodes)

    % % Commented lines were to make a relative distribution
    % testtypes = zeros([length(electrodes), 1]);
    % for i = 1:length(electrodes)
    %     testtypes(i) = combinationtype(electrodes(i, :));
    % end
    % testbarvals = zeros([8, 1]);
    % for i = 1:8
    %     testbarvals(i) = length(find(testtypes==i));
    % end
    % testbarvals = testbarvals./length(electrodes);
    
    types = zeros([n,1]);
    for i = 1:n
        types(i) = combinationtype(electrodes(testranking(i), :));
    end
    barvals = zeros([8, 1]);
    for i = 1:8
        barvals(i) = length(find(types==i));
    end
    % barvals = barvals./(n*testbarvals);
    bar(barvals);
end