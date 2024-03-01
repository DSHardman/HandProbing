% lines = readlines("../../handoutline.txt");
% 
% positions = zeros([180 2]);
% 
% for i = 1:length(lines)
%     line = lines(i);
%     position = str2double(split(line, "  "));
%     positions(i, :) = [position(end-1) position(end)];
% end
% 
% 
% % Generate random points within hand
% targetpositions = zeros([100, 2]);
% 
% n = 0;
% while n < 100
%     x = rand()*(max(positions(:,1))-min(positions(:, 1))) + min(positions(:, 1));
%     y = rand()*(max(positions(:,2))-min(positions(:, 2))) + min(positions(:, 2));
% 
%     if inpolygon(x,y,positions(:,1),positions(:,2))
%         n = n + 1;
%         targetpositions(n, :) = [x y];
%     end
% end

s = serialport("COM18",230400, "Timeout", 600);

n = 1020; % number of frames to record
alldata = zeros(n, 5568*2 + 4); % Final 4 should always be -1
times(n) = datetime();

current = 1; % how many stimulations have been measured?
for i = 1:n
    if mod(i, 10) == 0
        clf
    end

    if mod(i+5, 10) == 0
        plot(positions(:,1), positions(:,2));
        hold on
        scatter(targetpositions(current,1), targetpositions(current,2), 30, 'r', 'filled');
        current = current + 1
    end

    data = read(s, (5568*2 + 4), "int16");
    assert(length(find(data==-1)) == 4);
    alldata(i, :) = data;
    times(i) = datetime(); % save time at which frame finished collecting

    if current == 101 % Exit after last stimulation is recorded
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