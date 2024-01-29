s={steelbolts, melting};
legendlabel = {"none"; "steelbolts"; "melting"};


% if the last argument here is one, PCA uses only first entry. Leave blank
% to use all.
[coeff,score,latent,tsquared,explained, mu] = totalpca(s, legendlabel, "r10", 1);
% bhtouch.fingerprint = coeff(:, 1);

%%

function [coeff,score,latent,tsquared,explained, mu] = totalpca(s, legendlabel, type, numtrain)
    % Perform non-supervised clustering on all data at once
    allevents=[];

    % Optionally PCA on only first n entries
    if nargin == 3
        numtrain = length(s);
    end

    for i=1:numtrain
        if type == "r10"
            allevents = [allevents;(s{1,i}.rms10k)];
        elseif type == "r50"
            allevents = [allevents;(s{1,i}.rms50k)];
        elseif type == "r100"
            allevents = [allevents;(s{1,i}.rms100k)];
        elseif type == "p10"
            allevents = [allevents;(s{1,i}.phase10k)];
        elseif type == "p50"
            allevents = [allevents;(s{1,i}.phase50k)];
        elseif type == "p100"
            allevents = [allevents;(s{1,i}.phase100k)];
        end
    end
    [coeff,score,latent,tsquared,explained, mu] = pca(allevents);
        
    % subplot(1,3,1);
    % Pseudo-scatter for legend purposes
    my_colors; % current maximum 6
    scatter(nan, nan, 30, "k", "filled");
    hold on
    for i=1:length(s)
        scatter(nan, nan, 30, colors(i,:), "filled");
    end

    % Plot extra entries if only training on subset
    if nargin == 4
        for i=numtrain+1:length(s)
            if type == "r10"
                allevents = [allevents;(s{1,i}.rms10k)];
            elseif type == "r50"
                allevents = [allevents;(s{1,i}.rms50k)];
            elseif type == "r100"
                allevents = [allevents;(s{1,i}.rms100k)];
            elseif type == "p10"
                allevents = [allevents;(s{1,i}.phase10k)];
            elseif type == "p50"
                allevents = [allevents;(s{1,i}.phase50k)];
            elseif type == "p100"
                allevents = [allevents;(s{1,i}.phase100k)];
            end
        end
    end
    Y = (allevents-mu)*coeff(:,1:2);
    
    % Add scatter for each event in turn
    j = 0;
    for i=1:length(s)
        pcaevents(Y, s{1, i}, j, colors(i,:));
        j = j + size((s{1, i}.rms10k),1);
        hold on
    end
    legend(legendlabel);
    set(gcf, "color", "w");

    % % sumnumber = 1;
    % % heatmap(reshape([sum(abs(coeff(:, 1:sumnumber)).', 1).'; NaN], [30, 56]).');
    % subplot(1,3,2);
    % heatmap(reshape([abs(coeff(:, 1)); NaN], [30, 56]).');
    % title("PCA Fingerprint 1: " + string(explained(1)) + "%");
    % 
    % subplot(1,3,3);
    % heatmap(reshape([abs(coeff(:, 2)); NaN], [30, 56]).');
    % title("PCA Fingerprint 2: " + string(explained(2)) + "%");
    % 
    % set(gcf, 'Position', [55 464 1442 322]);
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