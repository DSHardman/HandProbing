s={touch presshuman pressrobot steelbolts};
legendlabel = {"none"; "touch"; "presshuman";...
                "pressrobot"; "steelbolts"};

% s={Htouch Hpresshuman Hpressglove};
% legendlabel = {"none"; "touch"; "presshuman"; "pressglove"};

% s={sctouch scglovepress};
% legendlabel = {"none"; "Stouch"; "Sglove"};

subplot(1,2,1);
convertor = totalScatter(s, legendlabel, "r10");
title("RMS");
subplot(1,2,2);
totalScatter(s, legendlabel, "p10");
title("Phase");

%% Functions
function convert = totalScatter(s, legendlabel, type)
    % Perform non-supervised clustering on all data at once
    allevents=[];
    for i=1:length(s)
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
    Y=tsne(allevents);
    convert = allevents\Y;
    
    % Pseudo-scatter for legend purposes
    my_colors; % current maximum 6
    scatter(nan, nan, 30, "k", "filled");
    hold on
    for i=1:length(s)
        scatter(nan, nan, 30, colors(i,:), "filled");
    end
    
    % Add scatter for each event in turn
    j = 0;
    for i=1:length(s)
        scatterevents(Y, s{1, i}, j, colors(i,:));
        j = j + size((s{1, i}.rms10k),1);
        hold on
    end
    legend(legendlabel);
end

function scatterevents(Y, recordingobject, startingindex, col)

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
        text(xloc+3, yloc, recordingobject.eventlabels(i), "color", col);

        start = startingindex + recordingobject.eventboundaries(i,2) + 5;
    end

    % Black scatter those after the final event
    scatter(Y(start:startingindex+size(recordingobject.rms10k, 1), 1),...
        Y(start:startingindex+size(recordingobject.rms10k, 1), 2),...
            10, "k", "filled");
end
