% s={touchsingle touch presshuman steelbolts melting damages pressrobot plasticcaps};
% titles = {"TouchSingle"; "Touch"; "PressHuman"; "SteelBolts"; "Melting";...
%     "Damages"; "PressRobot"; "PlasticCaps"};

s={touch presshuman steelbolts melting damages pressrobot plasticcaps};
titles = {"Touch"; "PressHuman"; "SteelBolts"; "Melting";...
    "Damages"; "PressRobot"; "PlasticCaps"};

similarities = zeros(length(s));
for i = 1:length(s)
    for j = 1:length(s)
        similarities(i,j) = dot(s{1,i}.fingerprint, s{1,j}.fingerprint);
        % similarities(i,j) = 24.667*(similarities(i,j)-0.45)+0.2; % scale line width for figure
    end
end

% heatmap(similarities);

group1 = [];
group2 = [];
weights = [];
for i = 1:length(titles)
    for j = i+1:length(titles)
        group1 = [group1; titles{i}];
        group2 = [group2; titles{j}];
        weights = [weights; similarities(i, j)];
    end
end

% weights = (weights-min(weights))*5 + 0.2;
% chordPlot(string(titles), table(group1, group2, 10*weights));

% Generate text file for chord diagram on http://www.datasmith.org/2018/06/02/a-bold-chord-diagram-generator/
textstring = "";
for i = 1:length(weights)
    textstring = textstring + group1(i) + ", " + group2(i) + ", " + string(abs(weights(i))) + "\n";
end
fid = fopen('connections.txt','wt');
fprintf(fid, textstring);
fclose(fid);

%% plot fingerprints

% my_colors

% To match chord diagram
% colors = (1/255)*[31 119 182;
%                 174 199 232;
%                 254 126 12;
%                 254 188 120;
%                 44 160 44;
%                 149 223 136;
%                 214 39 40;
%                 0 0 0];

colors = (1/255)*[141 199 129;
                188 175 211;
                244 192 139;
                253 254 158;
                71 109 174;
                222 34 129;
                179 93 38;
                0 0 0];

figure();
for i = 1:length(s)
    colors(i,:) = colors(6,:);
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