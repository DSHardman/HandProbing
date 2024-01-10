for n = 1:5
    ines = readlines("Raw/50k_ADAD_"+string(n)+"_1.txt");
    lines = lines(2:end-1);
    
    results = zeros([size(lines, 1), 3072]);
    for i = 1:size(lines, 1)
        line = double(split(lines(i), ', '));
        line = [0; double(line(2:end-1))];
        results(i, :) = line;
    end

    subplot(5,3,n*3-2);
    temporary = results(:, 1:3:end);
    heatmap(normalize(temporary(:, keeps), "range", [0 1]).', "colormap", gray);
    grid off
    subplot(5,3,n*3-1);
    temporary = results(:, 2:3:end);
    heatmap(normalize(temporary(:, keeps), "range", [0 1]).', "colormap", gray);
    grid off
    subplot(5,3,n*3);
    temporary = results(:, 3:3:end);
    heatmap(normalize(temporary(:, keeps), "range", [0 1]).', "colormap", gray);
    grid off
end