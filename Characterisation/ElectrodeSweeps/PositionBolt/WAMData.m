
for i = 4901:5000
    subplot(1,2,1);
    viscircles([0 0], 0.035);
    hold on
    scatter(positions(i,1), positions(i,2), 20, "r", "filled");
    axis equal

    subplot(1,2,2);

    weighted = zeros([4900, 1]);
    for j = 1:1679
        
        % channel = (1.1 - sqrt(positions(i,1)^2+positions(i,2)^2)/0.035)*(deltaresponses(1:4900, j));
        channel = deltaresponses(1:4900, j);
        channel = tanh(normalize(channel));
        weighted = weighted + deltaresponses(i,j)*channel;
    end

    scatter(positions(1:4900, 1), positions(1:4900, 2), 10, weighted, "filled");
    title(string(i));
    axis equal
    pause();
    clf;
end