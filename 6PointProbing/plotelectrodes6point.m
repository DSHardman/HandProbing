function plotelectrodes6point(ranking)
    load("electrodesfull.mat");
    electrodes = electrodes(ranking, :);

    viscircles([0 0], 1, 'color', 'k');
    hold on

    for i = 1:2
        plotnumber(electrodes(i), 'r');
    end

    for i = 3:4
        plotnumber(electrodes(i), 'b');
    end
end

function plotnumber(number, color)
    theta = 3*pi/2 - pi/8 - pi/2 - (number-1)*pi/4; % matches rotation of 6 point figure
    hold on

    [x, y] = pol2cart(theta, 1);
    scatter(x, y, 50, color, 'filled');
    xlim([-1.1 1.1]);
    ylim([-1.1 1.1]);
    axis square
end