% load("Weekend2.mat");
% load("Weekend2Conditions.mat");

averages = zeros([size(alldata, 1), 870]);
for i = 1:2:1740
    reading = smooth(mean(alldata(1:end,i+[1:1984:1725211]).'), 10)*22/1024;
    averages(:, (i+1)/2) = reading-reading(1);
end

ranking = fsrftest(averages, conditionsync(:, 1));
inputs = averages(:, ranking(1:50)).';
outputs = conditionsync(:, 1).';

net = fitnet(80);
[net,tr] = train(net,inputs,outputs);

testX = inputs(:,tr.testInd);
testT = outputs(:,tr.testInd);
testY = net(testX);

my_colors

plot(hours(conditiontimesync(tr.testInd)-conditiontimesync(1)), testY, 'linewidth', 2, 'Color', colors(3, :));
hold on
plot(hours(conditiontimesync(tr.testInd)-conditiontimesync(1)), testT, 'linewidth', 3, 'Color', colors(2, :));
box off
set(gca, 'linewidth', 2, 'FontSize', 15);
set(gcf, 'position', [246   456   914   300], 'color', 'w');