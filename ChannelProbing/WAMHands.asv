%% Plot individual activation maps
% A connection was clearly knocked shortly after 260th press, so data is
% truncated
responses = responsedowns(1:260, :) - responseups(1:260, :);
positions = positions(1:260, :);

% % Scale response with y position: from 1 at electrodes to F at fingertips 
% F = 2;
% scaledresponses = responses;
% for i = 1:260
%     factor = ((F-1)/145)*positions(i,2) + (41-12*F)/29;
%     scaledresponses(i,:) = responses(i,:)*factor;
% end
% responses = scaledresponses;

% Plot all activation maps in sets of 12
for n = 1:16
    figure();
    for i = 1:12
        subplot(3,4,i);
        scatter(positions(:,1), positions(:,2), 20, responses(:, (n-1)*12+i), 'filled');
        centre = mean(responses(:, (n-1)*12+i));
        range = std(responses(:, (n-1)*12+i));
        title(string((n-1)*12+i));
        xlim([0 185]);
        ylim([60 205]);
        if range ~= 0
            clim([centre-4*range, centre+4*range]); % color range set empirically
        end
        axis off
    end
    set(gcf, 'color', 'w');
    % print('ChannelHands'+string(n), '-dpng');
    % print('-vector','-dpdf','ChannelHands'+string(n));
    % close();
end

%% Attempt at WAMs

figure();
for test = 1:10
    testloc = 250+test;
    sum = zeros([250, 1]);
    for i = 1:192
        range = std(responses(1:250, i));
        if range ~= 0
            sum = sum + responses(testloc, i)*tanh((responses(1:250, i)-mean(responses(1:250, i)))/std(responses(1:250, i)));
        end
    end
    subplot(2,5,test);
    scatter(positions(1:250,1), positions(1:250,2), 20, sum, 'filled');
    hold on
    scatter(positions(testloc, 1), positions(testloc, 2), 40, 'r', 'filled');
    axis off
    title(string(testloc));
end
set(gcf, 'color', 'w');