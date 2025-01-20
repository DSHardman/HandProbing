s = serialport("COM17",115200, "Timeout", 600);

% stimulations = ["Full Grasp" "Finger Squeeze" "Middle Finger" "Thumb" "Nothing" "Ruler Base"];
% 
% % Repeat each action 10 times - randomise the order of each group
% order = [];
% for i = 1:10
%     order = [order randperm(6)];
% end
% allstimulations = [];
% for i = 1:60
%     allstimulations = [allstimulations stimulations(order(i))];
% end

desiredduration = 40; % in seconds
% n = round(desiredduration/2.33);
n = round(desiredduration/6.5);

n = 2;

% n = 1000; % number of frames to record
alldata = zeros(n, 5568*2 + 4); % Final 4 should always be -1
times(n) = datetime();

current = 1; % how many stimulations have been measured?
for i = 1:n
    % if mod(i, 10) == 0
    %     fprintf("Release\n");
    % end
    % 
    % if mod(i+5, 10) == 0
    %     fprintf(allstimulations(current) + "\n");
    %     current = current + 1;
    % end
    tic
    data = read(s, (5568*2 + 4), "int16");
    toc
    % assert(length(find(data==-1)) == 4);
    alldata(i, :) = data;
    times(i) = datetime(); % save time at which frame finished collecting

    % if current == 61 % Exit after last stimulation is recorded
    %     break
    % end

end

clear s

reading = HandCompare(alldata, times);

plot(data);
figure();
r10 = reading.rmsall();

r10 = alldata;
[coeff,score] = pca(r10);
[~,ranking] = sort(abs(coeff(:,1)), 'descend');
heatmap(normalize(r10(:, ranking), "range", [0 1]).', "colormap", gray); grid off

% % plot heatmaps
% subplot(2,1,1);
% heatmap(normalize(reading.rmsall(), "range", [0 1]).', "colormap", gray); grid off
% subplot(2,1,2);
% heatmap(normalize(reading.phaseall(), "range", [0 1]).', "colormap", gray); grid off