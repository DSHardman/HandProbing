function plotelectrodes(ranking)
    load("electrodes32.mat");
    electrodes = electrodes(ranking, :);

    % viscircles([0 0], 1, 'color', 'k');
    hold on

    [x1, y1] = plotnumber(electrodes(1), 'r');
    [x2, y2] = plotnumber(electrodes(2), 'r');

    % line([x1 x2], [y1 y2], 'color', 'r', 'linewidth', 1)

    [x3, y3] = plotnumber(electrodes(3), 'b');
    [x4, y4] = plotnumber(electrodes(4), 'b');

     % line([x3 x4], [y3 y4], 'color', 'b', 'linewidth', 1)

    % fill([x1 x2 x3 x4], [y1 y2 y3 y4], 'k', 'facealpha', 0.2, 'edgecolor', 'none');
    x = [x1; x2; x3; x4];
    y = [y1; y2; y3; y4];
    k = boundary(x, y);
    hold on;
    fill(x(k),y(k), 'k', 'facealpha', 0.005, 'edgecolor', 'none');
end

function [x, y] = plotnumber(number, color)
    theta = 3*pi/2 - pi/32 - (number-1)*pi/16;
    hold on

    [x, y] = pol2cart(theta, 1);
    %scatter(x, y, 50, color, 'filled');
    xlim([-1.1 1.1]);
    ylim([-2 2]);
    axis square
end