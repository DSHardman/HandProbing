% Given tetrapolar configuration, draw translucent polygon using those 4
% corners

function plotelectrodes32fill(ranking)
    load("electrodes32.mat");
    electrodes = electrodes(ranking, :);

    hold on

    [x1, y1] = plotnumber(electrodes(1));
    [x2, y2] = plotnumber(electrodes(2));

    [x3, y3] = plotnumber(electrodes(3));
    [x4, y4] = plotnumber(electrodes(4));

    x = [x1; x2; x3; x4];
    y = [y1; y2; y3; y4];
    k = boundary(x, y);

    fill(x(k),y(k), 'k', 'facealpha', 0.05, 'edgecolor', 'none');
end

function [x, y] = plotnumber(number)
    theta = 3*pi/2 - pi/32 - (number-1)*pi/16;
    hold on

    [x, y] = pol2cart(theta, 1);
    xlim([-1.1 1.1]);
    ylim([-2 2]);
    axis square
end