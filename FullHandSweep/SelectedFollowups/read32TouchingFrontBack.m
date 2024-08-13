lines = readlines("../../handoutline.txt");

positions = zeros([180 2]);

for i = 1:length(lines)
    line = lines(i);
    position = str2double(split(line, "  "));
    positions(i, :) = [position(end-1) position(end)];
end


% Generate random points within hand
targetpositions = zeros([100, 3]); % 3rd is boolean: 0 front, 1 back
targetpositions(:, 3) = round(rand(100, 1)); % Randomly generate

n = 0;
while n < 100
    x = rand()*(max(positions(:,1))-min(positions(:, 1))) + min(positions(:, 1));
    y = rand()*(max(positions(:,2))-min(positions(:, 2))) + min(positions(:, 2));

    if inpolygon(x,y,positions(:,1),positions(:,2))
        n = n + 1;
        targetpositions(n, 1:2) = [x y];
    end
end

s = serialport("COM19",230400, "Timeout", 600);

n = 5; % number of frames to record
% alldata = zeros(n, 5568*2 + 4); % Final 4 should always be -1
alldata = zeros(2*n, 5568*2 + 4); % Final 4 should always be -1
times(2*n) = datetime();

% Create figure and warn of first location
figure();
if targetpositions(1, 3)
    set(gcf, 'color', 'g');
    title("BACK");
else
    set(gcf, 'color', 'w');
    title("FRONT");
end
set(gca, 'color', 'none');
set(gca,'XColor', 'none','YColor','none');

current = 1; % how many stimulations have been measured?
for i = 1:n
    clf
    if targetpositions(current, 3)
        set(gcf, 'color', 'g');
        title("BACK");
    else
        set(gcf, 'color', 'w');
        title("FRONT");
    end
    set(gca, 'color', 'none');
    set(gca,'XColor', 'none','YColor','none')

    data = read(s, (5568*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i*2-1, :) = data;
    times(i*2-1) = datetime(); % save time at which frame finished collecting

    current
    plot(positions(:,1), positions(:,2), 'color', 'k', 'linewidth', 2);
    hold on
    if targetpositions(current, 3)
        scatter(targetpositions(current,1), targetpositions(current,2), 50, 'w', 'filled');
        set(gcf, 'color', 'g');
    else
        scatter(targetpositions(current,1), targetpositions(current,2), 50, 'r', 'filled');
        set(gcf, 'color', 'w');
    end
    axis off
    xlim([-150 -50]);
    title(current);
    current = current + 1;

    % data = read(s, (5568*2 + 4), "int16");
    data = read(s, (5568*2 + 4), "int16");
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