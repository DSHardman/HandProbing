function plotscores(scores1, YTest1, scores2, YTest2)
    lines = readlines("../handoutline.txt");
    positions = zeros([180 2]);

    for i = 1:length(lines)
        line = lines(i);
        position = str2double(split(line, "  "));
        positions(i, :) = [position(end-1) position(end)];
    end

    load("../FullHandSweep/SelectedFollowups/multicats.mat");

    plot(positions(:, 1), positions(:, 2), 'color', 'k');
    hold on
    plot(positions(:, 1)+max(positions(:, 1)), positions(:, 2), 'color', 'k');

    for i = 1:10
        if i == YTest1
            rectcol = 'r';
        else
            rectcol = 'b';
        end
        rectangle('Position', [multicats(i, 1)-0.5 multicats(i, 2), 1, 10*scores1(i)],...
            'FaceColor', rectcol);

        if i == YTest2
            rectcol = 'r';
        else
            rectcol = 'b';
        end
        rectangle('Position', [multicats(i, 1)-0.5+max(positions(:, 1)) multicats(i, 2), 1, 10*scores2(i)],...
            'FaceColor', rectcol);

    end

    scatter(multicats(:, 1), multicats(:, 2), 30, 'k', 'filled');
    scatter(multicats(YTest1, 1), multicats(YTest1, 2), 30, 'r', 'filled');

    scatter(multicats(:, 1)++max(positions(:, 1)), multicats(:, 2), 30, 'k', 'filled');
    scatter(multicats(YTest2, 1)++max(positions(:, 1)), multicats(YTest2, 2), 30, 'r', 'filled');

    axis off
    set(gcf, 'position', [167 369 1020 420]);
end