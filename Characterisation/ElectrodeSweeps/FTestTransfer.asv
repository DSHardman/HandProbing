load("Data/Extracted/Recordings2D.mat");
load("PositionBolt/MLTests/rankings.mat");

figure();
transferFTest({steelbolts pressrobot}, combsranking, 50);
axis equal
% figure();
% transferFTest({steelbolts melting}, combsranking, 50);
% figure();
% transferFTest({steelbolts pressrobot}, combsranking, 50);
% figure();
% transferFTest({steelbolts presshuman}, combsranking, 50);

%%

function transferFTest(s, ranking, n)

    ranking = mod(ranking(1:n)-1, 1679)+1;

    allevents = s{1,1}.rms10k;
    [coeff, ~, ~, ~, ~, mu] = pca(allevents(:, ranking));
        
    my_colors; % current maximum 6
    scatter(nan, nan, 30, "k", "filled");
    hold on

    % Plot extra entries
    for i=2:length(s)
        allevents = [allevents;(s{1,i}.rms10k)];
    end
    Y = (allevents(:, ranking)-mu)*coeff(:,1:2);
    
    % Add scatter for each event in turn
    j = size((s{1, 1}.rms10k),1);
    for i=2:length(s)
        pcaevents(Y, s{1, i}, j, colors(i,:));
        j = j + size((s{1, i}.rms10k),1);
        hold on
    end
    set(gcf, "color", "w");
    xlabel("PCA 1");
    ylabel("PCA 2");
    set(gca, 'linewidth', 2, 'fontsize', 18);
    box off
    axis square
    set(gca,'XColor','k','YColor','k');
end

function pcaevents(Y, recordingobject, startingindex, col)

    % If no events are defined, plot path over time then exit
    if isempty(recordingobject.eventboundaries)
        plot(Y(startingindex+1:startingindex+size(recordingobject.rms10k, 1), 1),...
            Y(startingindex+1:startingindex+size(recordingobject.rms10k, 1), 2),...
            "Color", col, "linewidth", 2);
        
        % scatter(Y(startingindex+1, 1), Y(startingindex+1, 2), 20, col, "filled"); % blob at start
        return
    end

    my_colors;
    start = startingindex+1;
    for i = 1:size(recordingobject.eventboundaries, 1)
        % Black scatter those before each event
        scatter(Y(start:startingindex+recordingobject.eventboundaries(i,1)-5, 1),...
            Y(start:startingindex+recordingobject.eventboundaries(i,1)-5, 2),...
            50, "k", "filled");

        % Scatter each event with a different marker in the color defined
        scatter(Y(startingindex+recordingobject.eventboundaries(i,1)+2:...
            startingindex+recordingobject.eventboundaries(i,2)-2, 1),...
            Y(startingindex+recordingobject.eventboundaries(i,1)+2:...
            startingindex+recordingobject.eventboundaries(i,2)-2, 2),...
            50, colors(i,:), "filled");

        % % Add text labels offset from cluster centroid
        % xloc = mean(Y(startingindex+recordingobject.eventboundaries(i,1):...
        %     startingindex+recordingobject.eventboundaries(i,2), 1));
        % yloc = mean(Y(startingindex+recordingobject.eventboundaries(i,1):...
        %     startingindex+recordingobject.eventboundaries(i,2), 2));
        % text(xloc+0.002, yloc, recordingobject.eventlabels(i), "color", colors(i,:));

        start = startingindex + recordingobject.eventboundaries(i,2) + 5;
    end

    % Black scatter those after the final event
    scatter(Y(start:startingindex+size(recordingobject.rms10k, 1), 1),...
        Y(start:startingindex+size(recordingobject.rms10k, 1), 2),...
            50, "k", "filled");

end