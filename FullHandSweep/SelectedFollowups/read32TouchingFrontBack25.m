lines = readlines("../../handoutline.txt");
load("multicats.mat");
multicats1 = multicats(1:2:end, :);
multicats2 = multicats(2:2:end, :);

positions = zeros([180 2]);

for i = 1:length(lines)
    line = lines(i);
    position = str2double(split(line, "  "));
    positions(i, :) = [position(end-1) position(end)];
end


% Generate random points within hand
targetpositions = zeros([25, 2]); % 10 locations, 10 classes - loop through all 100 combinations
order = randperm(25);
for i = 1:25
    targetpositions(i, 1) = rem(order(i), 5) + 1;
    targetpositions(i, 2) = ceil(order(i)/5);
end

s = serialport("COM20",230400, "Timeout", 600);

n = 27; % number of frames to record
alldata = zeros(4*n, 5140*2 + 4); % Final 4 should always be -1
times(2*n) = datetime();

figure();
set(gcf, 'color', 'b'); % Begin with switch at cold position 
set(gca, 'color', 'none');
set(gca,'XColor', 'none','YColor','none');

for i = 1:3
    i
    data = read(s, (5140*2 + 4), "int16");
end

current = 1; % how many stimulations have been measured?
for i = 1:n
    clf

    data = read(s, (5140*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*4-3, :) = data;
    data = read(s, (5140*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*4-2, :) = data;
    times(i*2-1) = datetime(); % save time at which frame finished collecting

    current

    % subplot(1,2,1);
    set(gca, 'color', 'none');
    set(gca,'XColor', 'none','YColor','none');
    plot(positions(:,1), positions(:,2), 'color', 'k', 'linewidth', 2);
    hold on
    scatter(multicats(:, 1), multicats(:, 2), 10, 'k', 'filled');
    scatter(multicats1(targetpositions(current,1), 1), multicats1(targetpositions(current,1), 2), 80, 'w', 'filled');
    axis off
    xlim([-150 -50]);
    scatter(multicats2(targetpositions(current,2), 1), multicats2(targetpositions(current,2), 2), 80, 'g', 'filled');

    sgtitle(current);
    current = current + 1;
    set(gcf, 'position', [220         198        1042         523]);

    data = read(s, (5140*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*4-1, :) = data;
    data = read(s, (5140*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*4, :) = data;
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