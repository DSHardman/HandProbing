load("StimulationTest.mat");
data = [reading.rmsanalytic reading.phaseanalytic];

% stimints = zeros([59 1]);
% for i = 1:59
%     if allstimulations(i) == "Nothing"
%     stimints(i) = 1;
%     elseif allstimulations(i) == "Middle Finger"
%     stimints(i) = 2;
%     elseif allstimulations(i) == "Thumb"
%     stimints(i) = 3;
%     elseif allstimulations(i) == "Ruler Base"
%     stimints(i) = 4;
%     elseif allstimulations(i) == "Finger Squeeze"
%     stimints(i) = 5;
%     elseif allstimulations(i) == "Full Grasp"
%     stimints(i) = 6;
%     end
% end
% 
% responses = zeros([59, size(data, 2)]);
% for i = 1:59
%     responses(i, :) = mean(data((i-1)*10+6:(i-1)*10+9, :)) - mean(data((i-1)*10+1:(i-1)*10+4, :));
% end
% 
% ranking = fsrftest(responses, stimints);
% totalpca(data(:, ranking(1:50)), allstimulations);

totalpca(data, allstimulations);
set(gcf, 'position', [488    84   368   760], 'color', 'w');

%%

function [coeff,score,latent,tsquared,explained, mu] = totalpca(s, allstimulations)
    % Perform non-supervised clustering on all data at once

    [coeff,score,latent,tsquared,explained, mu] = pca(s);
        
    % % Pseudo-scatter for legend purposes
    my_colors; % current maximum 6
    scatter(nan, nan, 30, "k", "filled");
    hold on
    for i=1:5
        scatter(nan, nan, 50, colors(i,:), "filled");
    end

    Y = (s-mu)*coeff(:,1:2);
    hold on
    for i = 1:59
        inds = 1+(i-1)*10:4+(i-1)*10;
        scatter(Y(inds, 1), Y(inds,2), 50, 'k', 'filled');
        hold on
        inds = 6+(i-1)*10:9+(i-1)*10;
        if allstimulations(i) == "Middle Finger"
            col = colors(1,:);
            scatter(Y(inds, 1), Y(inds,2), 50, col, 'filled');
        elseif allstimulations(i) == "Full Grasp"
            col = colors(3,:);
            scatter(Y(inds, 1), Y(inds,2), 50, col, 'filled');
        elseif allstimulations(i) == "Finger Squeeze"
        elseif allstimulations(i) == "Thumb"
            col = colors(4,:);
            scatter(Y(inds, 1), Y(inds,2), 50, col, 'filled');
        elseif allstimulations(i) == "Ruler Base"
            % col = colors(4,:);
            % scatter(Y(inds, 1), Y(inds,2), 50, col, 'filled');
        elseif allstimulations(i) == "Nothing"
            col = 'k';
            scatter(Y(inds, 1), Y(inds,2), 50, col, 'filled');
        else
            fprintf("ERROR: Stimulation not identified");
        end
    end

    scatter(Y(591:595, 1), Y(591:595,2), 50, 'k', 'filled');
    % 
    % % Add scatter for each event in turn
    % j = 0;
    % for i=1:length(s)
    %     pcaevents(Y, s{1, i}, j, colors(i,:));
    %     j = j + size((s{1, i}.rms10k),1);
    %     hold on
    % end
    % legend(legendlabel);
    % set(gcf, "color", "w");

end

function pcaevents(Y, recordingobject, startingindex, col)

    % If no events are defined, plot path over time then exit
    if isempty(recordingobject.eventboundaries)
        plot(Y(startingindex+1:startingindex+size(recordingobject.rms10k, 1), 1),...
            Y(startingindex+1:startingindex+size(recordingobject.rms10k, 1), 2),...
            "Color", col);
        
        % scatter(Y(startingindex+1, 1), Y(startingindex+1, 2), 20, col, "filled"); % blob at start
        xlabel("PCA 1");
        ylabel("PCA 2");
        return
    end

    markers = ["o", "+", "*", "x", "_", "|", "square", "diamond"];
    start = startingindex+1;
    for i = 1:size(recordingobject.eventboundaries, 1)
        % Black scatter those before each event
        scatter(Y(start:startingindex+recordingobject.eventboundaries(i,1)-5, 1),...
            Y(start:startingindex+recordingobject.eventboundaries(i,1)-5, 2),...
            10, "k", "filled");

        % Scatter each event with a different marker in the color defined
        scatter(Y(startingindex+recordingobject.eventboundaries(i,1):...
            startingindex+recordingobject.eventboundaries(i,2), 1),...
            Y(startingindex+recordingobject.eventboundaries(i,1):...
            startingindex+recordingobject.eventboundaries(i,2), 2),...
            15, col, markers(i));

        % Add text labels offset from cluster centroid
        xloc = mean(Y(startingindex+recordingobject.eventboundaries(i,1):...
            startingindex+recordingobject.eventboundaries(i,2), 1));
        yloc = mean(Y(startingindex+recordingobject.eventboundaries(i,1):...
            startingindex+recordingobject.eventboundaries(i,2), 2));
        text(xloc+0.002, yloc, recordingobject.eventlabels(i), "color", col);

        start = startingindex + recordingobject.eventboundaries(i,2) + 5;
    end

    % Black scatter those after the final event
    scatter(Y(start:startingindex+size(recordingobject.rms10k, 1), 1),...
        Y(start:startingindex+size(recordingobject.rms10k, 1), 2),...
            10, "k", "filled");

    xlabel("PCA 1");
    ylabel("PCA 2");
end