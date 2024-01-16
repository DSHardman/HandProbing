s={touchsingle touch presshuman steelbolts melting damages pressrobot plasticcaps};
titles = {"TouchSingle"; "Touch"; "PressHuman"; "SteelBolts"; "Melting";...
    "Damages"; "PressRobot"; "PlasticCaps"};

similarities = zeros(length(s));
for i = 1:length(s)
    for j = 1:length(s)
        similarities(i,j) = dot(s{1,i}.fingerprint, s{1,j}.fingerprint);
        % similarities(i,j) = 24.667*(similarities(i,j)-0.45)+0.2; % scale line width for figure
    end
end

heatmap(similarities);

%% plot fingerprints

my_colors
figure();
for i = 1:length(s)
    subplot(1,length(s), i);
    s{1,i}.plotfingerprint();
    grid off
    colorbar off
    title(titles(i));
    map = [(colors(i,1):(1-colors(i,1))/500:1).',...
        (colors(i,2):(1-colors(i,2))/500:1).',...
        (colors(i,3):(1-colors(i,3))/500:1).'];
    colormap(gca, flipud(map));
end
set(gcf, 'Position', [42         554        1388         204]);