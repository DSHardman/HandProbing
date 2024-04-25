load("StimulationTest.mat");
data = reading.rmsanalytic();
% 
% series = mean(data(1:125, 1741:2262).');
% plot(seconds(times(1:125)-times(1)), series./series(1), 'color', 'k', 'linewidth', 2);

series = mean(data(1:125, 1:783).');
plot(seconds(times(1:125)-times(1)), series./series(1), 'color', 'b', 'linewidth', 2);


% plot(seconds(times(1:125)-times(1)), mean(data(1:125, 2002:2088).'), 'color', 'k', 'linewidth', 2);
set(gca, 'fontsize', 15, 'linewidth', 2);
box off
xlabel("Time (s)");
ylabel("Mean Response (Relative)");
set(gcf, 'Position', [793   556   640   200]);