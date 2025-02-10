medianfrontresponses = zeros(size(responses));
medianbackresponses = zeros(size(responses));

radius = 10/3.32; % In mm, with 3.32 correction factor

for i = 1:size(targetpositions, 1)
    % Calculate front medians
    includeindex = zeros([size(targetpositions, 1), 1]);
    for j = 1:size(targetpositions, 1)
        if rssq(targetpositions(i,1:2)-targetpositions(j,1:2)) < radius
            includeindex(j) = 1;
        end
    end
    medianfrontresponses(i, :) = median(responses(boolean(includeindex), :));

    % Calculate back medians
    includeindex = zeros([size(targetpositions, 1), 1]);
    for j = 1:size(targetpositions, 1)
        if rssq(targetpositions(i,3:4)-targetpositions(j,3:4)) < radius
            includeindex(j) = 1;
        end
    end
    medianbackresponses(i, :) = median(responses(boolean(includeindex), :));
end