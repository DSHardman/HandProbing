%% Stage 1: each side treated separately

averageresponses = zeros([20, 5100]);

for i = 1:10
    idx = find(alltargets(1:500,1)==i);
    averageresponses(i, :) = mean(rms(idx, :));
end

for i = 1:10
    idx = find(alltargets(1:500,2)==i);
    averageresponses(i+10, :) = mean(rms(idx, :));
end

naverageresponses = normalize(averageresponses, 2);

for n = 1:100
    dots = zeros([20, 1]);
    for i = 1:20
        dots(i) = dot(rms(500+n, :), naverageresponses(i,:));
    end
    subplot(1,2,1);
    plot(dots(1:10));
    hold on
    line([alltargets(500+n, 1) alltargets(500+n, 1)], [min(dots(1:10)) max(dots(1:10))], 'color', 'k');

    subplot(1,2,2);
    plot(dots(11:20));
    hold on
    line([alltargets(500+n, 2) alltargets(500+n, 2)], [min(dots(11:20)) max(dots(11:20))], 'color', 'k');

    title(string(i));
    pause();
    clf
end

%% Stage 2: each combination treated separately

averageresponses = zeros([100, 5100]);

for i = 1:100
    idx = find(singletargets(1:500)==i);
    averageresponses(i, :) = mean(rms(idx, :));
end
naverageresponses = normalize(averageresponses, 2);

for n = 1:100
    dots = zeros([100, 1]);
    for i = 1:100
        dots(i) = dot(rms(500+n, :), naverageresponses(i,:));
    end
    plot(dots);
    hold on
    line([alltargets(500+n, 1) alltargets(500+n, 1)], [min(dots) max(dots)], 'color', 'k');

    title(string(n));
    pause();
    clf
end