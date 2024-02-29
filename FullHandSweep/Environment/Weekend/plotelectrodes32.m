function plotelectrodes32(ranking)
    load("electrodes32.mat");
    electrodes = electrodes(ranking, :);

    viscircles([0 0], 1, 'color', 'k');
    hold on

    plotnumber(electrodes(1), 'r');
    plotnumber(electrodes(2), 'r');

    plotnumber(electrodes(3), 'b');
    plotnumber(electrodes(4), 'b');

end

function [x, y] = plotnumber(number, color)
    theta = 3*pi/2 - pi/32 - (number-1)*pi/16;
    hold on

    [x, y] = pol2cart(theta, 1);
    scatter(x, y, 50, color, 'filled');
    xlim([-1.1 1.1]);
    ylim([-2 2]);
    axis square
end