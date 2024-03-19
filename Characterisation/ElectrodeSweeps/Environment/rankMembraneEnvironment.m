load("MembraneEnvironment.mat");

%% Total ranking: RMS & Phase Simultaneously

% Correlation to humidity (absolute) - rank using this...
coefficients = zeros([size(responses, 2), 1]);
for i = 1:size(responses, 2)
    R = corrcoef(conditions(:, 2), responses(:,i));
    if ~isnan(R(1,2))
        coefficients(i) = abs(R(1,2));
    end
end

[~, ranking] = sort(coefficients, "descend");

%% Visualise Total Rankings
% 
% figure();
% imshow(reshape(mod(ranking,2), [1984 870]).');

types = zeros([50, 1]);

figure();
for i = 1:50
    % subplot(4,5,i);
    % plotelectrodes(ceil(ranking(i)/2));
    % hold on
    % if mod(ranking(i),2)==0
    %     text(0,0,"PHASE");
    % else
    %     text(0,0,"RMS");
    % end
end

%% Seperate rankings to determine information-rich channels

combinedscore = zeros([size(ranking,1)/2, 1]);
for i = 1:size(ranking,1)/2
    if mod(i,10000)==0
        i
    end
    combinedscore(i) = find(ranking==2*i) + find(ranking==2*i-1);
end

[~, combinedranking] = sort(combinedscore, "ascend");