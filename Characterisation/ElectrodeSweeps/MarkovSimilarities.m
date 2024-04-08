s={touch presshuman steelbolts melting damages pressrobot plasticcaps};
titles = {"Touch"; "PressHuman"; "SteelBolts"; "Melting";...
    "Damages"; "PressRobot"; "PlasticCaps"};

% similarities = zeros(length(s));
% for i = 1:length(s)
%     for j = 1:length(s)
%         similarities(i,j) = dot(s{1,i}.coeffs, s{1,j}.coeffs);
%     end
% end
% 
% % heatmap(similarities);
% 
% group1 = [];
% group2 = [];
% weights = [];
% for i = 1:length(titles)
%     for j = i+1:length(titles)
%         group1 = [group1; titles{i}];
%         group2 = [group2; titles{j}];
%         weights = [weights; similarities(i, j)];
%     end
% end
% 
% 
% 
% % Generate text file for chord diagram on http://www.datasmith.org/2018/06/02/a-bold-chord-diagram-generator/
% textstring = "";
% for i = 1:length(weights)
%     textstring = textstring + group1(i) + ", " + group2(i) + ", " + string(abs(weights(i))) + "\n";
% end
% fid = fopen('connections.txt','wt');
% fprintf(fid, textstring);
% fclose(fid);

%% plot fingerprints

colors = (1/255)*[222 34 129];

figure();
for i = 1:length(s)
    subplot(1,length(s), i);
    s{1,i}.plotfingerprint();
    grid off
    colorbar off
    title(titles(i));
    map = [(colors(1):(1-colors(1))/1680:1).',...
        (colors(2):(1-colors(2))/1680:1).',...
        (colors(3):(1-colors(3))/1680:1).'];
    colormap(map);
    %colormap(gca, flipud(map));
end
set(gcf, 'Position', [42         554        1388         204]);

%% Best in general
modalities = {damages melting touch steelbolts pressrobot};

totalfingerprint = zeros([1679, 1]);
for i = 1:5
    totalfingerprint = totalfingerprint + modalities{1,i}.fingerprint();
end
totalfingerprint = totalfingerprint./5;

colors = (1/255)*[38 34 222];

heatmap(reshape([totalfingerprint; NaN], [30, 56]).',...
    'XDisplayLabels',NaN*ones(30,1), 'YDisplayLabels',NaN*ones(56,1));
grid off
colorbar off
map = [(colors(1):(1-colors(1))/1680:1).',...
    (colors(2):(1-colors(2))/1680:1).',...
    (colors(3):(1-colors(3))/1680:1).'];
colormap(map);

%% Most unique

colors = (1/255)*[34 150 20];

figure();
for i = 7%:length(s)
    subplot(1,length(s), i);
    uniquefingerprint = totalfingerprint-s{1,i}.fingerprint();
    heatmap(reshape([uniquefingerprint; NaN], [30, 56]).',...
        'XDisplayLabels',NaN*ones(30,1), 'YDisplayLabels',NaN*ones(56,1));
    grid off
    colorbar off
    title(titles(i));
    map = [(colors(1):(1-colors(1))/1680:1).',...
        (colors(2):(1-colors(2))/1680:1).',...
        (colors(3):(1-colors(3))/1680:1).'];
    colormap(flipud(map));
    %colormap(gca, flipud(map));
    clim([-1500 1500]);
end
set(gcf, 'Position', [42         554        1388         204]);

%% Proof plots 0

modalities = {plasticcaps steelbolts touch pressrobot presshuman};

for i = 1:5
    subplot(5,1,i);
    [~,inds] = sort(modalities{1,i}.fingerprint(), "ascend");
    fingerbarall(inds(1), modalities);
    ylim([0 0.06]);
end

%% Proof plots 1
modalities = {plasticcaps steelbolts touch pressrobot presshuman};

[~,inds] = sort(totalfingerprint, "ascend");
fingerbarall(inds(1), modalities);


%% Proof plots 2
load("Data/Extracted/Uniques.mat");
modalities = {steelbolts touch pressrobot presshuman};

[~,inds] = sort(totalfingerprint, "ascend");
initialresponses = fingerbar(inds(1), modalities);
clf

subplot(1,4,1);
[~,inds] = sort(uniquesteel, "descend");
fingerbar(inds(1), modalities, initialresponses);
ylim([0 1.2]);

subplot(1,4,2);
[~,inds] = sort(uniquetouch, "descend");
fingerbar(inds(1), modalities, initialresponses);
ylim([0 1.2]);

subplot(1,4,3);
[~,inds] = sort(uniquepressrobot, "descend");
fingerbar(inds(1), modalities, initialresponses);
ylim([0 1.2]);

subplot(1,4,4);
[~,inds] = sort(uniquepresshuman, "descend");
fingerbar(inds(1), modalities, initialresponses);
ylim([0 1.2]);

function responsemags = fingerbar(channel, modalities, normresponses)
    responsemags = zeros([length(modalities), 1]);
    for i = 1:length(modalities)
        data = modalities{1,i}.rms10k();
        sum = 0;
        for j = 1:7
            sum = sum + abs(mean(data((j-1)*40+[30:38], channel))-...
                mean(data((j-1)*40+[7:15], channel)));
        end
        responsemags(i) = sum/7;
    end
    if nargin==3
        responsemags = responsemags./normresponses;
    end
    bar(responsemags);
    set(gcf, 'position', [489   486   430   160], 'color', 'w');
    box off
end

function fingerbarall(channel, modalities)
    responsemags = zeros([length(modalities), 1]);
    for i = 1:length(modalities)
        data = modalities{1,i}.rms10k();
        for j = 1:3
            responsemags(i, j) = abs(mean(data((j-1)*40+[30:38], channel))-...
                mean(data((j-1)*40+[7:15], channel)));
        end
    end
    bar(responsemags);
    set(gcf, 'position', [489   486   430   160], 'color', 'w');
    box off
end
