lines = readlines("../../handoutline.txt");
load("multicats.mat");

positions = zeros([180 2]);

for i = 1:length(lines)
    line = lines(i);
    position = str2double(split(line, "  "));
    positions(i, :) = [position(end-1) position(end)];
end

% Generate random points within hand
targetpositions = zeros([100, 4]); % x/y/front, x/y back

n = 0;
while n < 100
    % Random on front
    x = rand()*(max(positions(:,1))-min(positions(:, 1))) + min(positions(:, 1));
    y = rand()*(max(positions(:,2))-min(positions(:, 2))) + min(positions(:, 2));
    if inpolygon(x,y,positions(:,1),positions(:,2))
        n = n + 1;
        targetpositions(n, 1:2) = [x y];
    end
end
n = 0;
while n < 100
    % Random on back
    x = rand()*(max(positions(:,1))-min(positions(:, 1))) + min(positions(:, 1));
    y = rand()*(max(positions(:,2))-min(positions(:, 2))) + min(positions(:, 2));
    if inpolygon(x,y,positions(:,1),positions(:,2))
        n = n + 1;
        targetpositions(n, 3:4) = [x y];
    end
end


s = serialport("COM17",230400, "Timeout", 600);

fprintf("Starting...\n");
for i = 1:5
    i
    data = read(s, (5100*2 + 4), "int16");
end

n = 102; % number of frames to record
alldata = zeros(2*n, 5100*2 + 4); % Final 4 should always be -1
times(2*n) = datetime();

figure();
set(gcf, 'color', 'b'); % Begin with switch at cold position 
set(gca, 'color', 'none');
set(gca,'XColor', 'none','YColor','none');

current = 1; % how many stimulations have been measured?
for i = 1:n
    clf
    if current == 25 || current == 75 % Turn peltier to hot and wait 5 minutes
        set(gcf, 'color', 'r');
        tic
        while toc < 120
            toc
            read(s, (5100*2 + 4), "int16");
        end
    elseif current == 50 % Turn peltier to cold and wait 5 minutes
        set(gcf, 'color', 'b');
        tic
        while toc < 120
            toc
            read(s, (5100*2 + 4), "int16");
        end
    end

    data = read(s, (5100*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*2-1, :) = data;
    times(i*2-1) = datetime(); % save time at which frame finished collecting

    current

    % subplot(1,2,1);
    set(gca, 'color', 'none');
    set(gca,'XColor', 'none','YColor','none');
    plot(positions(:,1), positions(:,2), 'color', 'k', 'linewidth', 2);
    hold on
    scatter(multicats(:, 1), multicats(:, 2), 10, 'k', 'filled');
    scatter(targetpositions(current,1), targetpositions(current,2), 80, 'w', 'filled');
    axis off
    xlim([-150 -50]);
    scatter(targetpositions(current,3), targetpositions(current,4), 80, 'g', 'filled');

    % title("FRONT");
    % 
    % subplot(1,2,2);
    % set(gca, 'color', 'none');
    % set(gca,'XColor', 'none','YColor','none');
    % plot(positions(:,1), positions(:,2), 'color', 'k', 'linewidth', 2);
    % hold on
    % scatter(multicats(targetpositions(current,2), 1), multicats(targetpositions(current,2), 2), 50, 'w', 'filled');
    % axis off
    % xlim([-150 -50]);
    % title("BACK");

    sgtitle(current);
    current = current + 1;
    set(gcf, 'position', [220         198        1042         523]);

    data = read(s, (5100*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*2, :) = data;
    times(i*2) = datetime(); % save time at which frame finished collecting

    if current == 102 % Exit after last stimulation is recorded
        break
    end

end

clear s

% reading = HandCompare(alldata, times);
% 
% % plot heatmaps
% subplot(2,1,1);
% heatmap(normalize(reading.rmsall(), "range", [0 1]).', "colormap", gray); grid off
% subplot(2,1,2);
% heatmap(normalize(reading.phaseall(), "range", [0 1]).', "colormap", gray); grid off