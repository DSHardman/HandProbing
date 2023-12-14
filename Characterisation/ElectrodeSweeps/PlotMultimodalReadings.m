clear device
device = serialport("COM11",9600);

for i=1:1
    data = readline(device); 
    i
end

baseline = str2num(data);

while (1)
    data = readline(device);
    data = str2num(data);

    subplot(1,2,1);
    plot(data([1:1680 3361:5010 6721:8400]), 'color', 'b', 'linewidth', 1);
    set(gca, 'color', 'w', 'linewidth', 2, 'fontsize', 15);
    set(gcf, 'color', 'w');
    box off
    xlabel("Electrode Combination");
    ylabel("RMS");
    ylim([0 2]);

    subplot(1,2,2);
    plot(data([1681:3360 5011:6720 8401:10080]), 'color', 'r', 'linewidth', 1);
    set(gca, 'color', 'w', 'linewidth', 2, 'fontsize', 15);
    set(gcf, 'color', 'w');
    box off
    xlabel("Electrode Combination");
    ylabel("Phase");
    ylim([0 7]);

    drawnow();
end

