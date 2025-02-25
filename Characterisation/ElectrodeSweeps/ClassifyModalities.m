% Classify events from 2D dataset, using eventboundaries & eventlabels
% Plot graphs to see classification success with number of electrodes

% Calls autogenerated trainClassifier.m with matlab defaults
% Classifying A, B, C, AB, AC, BC, O, cases for all
% 
% a_touch = modalitypredict(touch);
% a_human = modalitypredict(presshuman);
% a_robot = modalitypredict(pressrobot);
% a_steel = modalitypredict(steelbolts);
% save("ClassifyModalitiesData.mat", "a_touch", "a_human", "a_robot", "a_steel");

% Compare with analytic electrode configurations
% pca_acc = modalitypredict(pressrobot);
% opop_acc = modalitypredict(pressrobot, oppoppinds);
% opad_acc = modalitypredict(pressrobot, oppadinds);
% adad_acc = modalitypredict(pressrobot, adadinds);
% save("ClassifyModalitiesRobotData.mat", "pca_acc", "opop_acc", "opad_acc", "adad_acc");

% Compare different morphologies
% a_touch_H = modalitypredict(Htouch);
% a_press_H = modalitypredict(Hpresshuman);
% a_glove_H = modalitypredict(Hpressglove);
% a_touch_bc = modalitypredict(bctouch);
a_touch_sc = modalitypredict(sctouch);
a_glove_sc = modalitypredict(scglovepress);

a_touch_bc = modalitypredict(bctouch);
a_glove_bc = modalitypredict(bcglovepress);

a_touch_sh = modalitypredict(shtouch);
a_glove_sh = modalitypredict(shglovepress);

a_touch_bh = modalitypredict(bhtouch);
a_glove_bh = modalitypredict(bhglovepress);

save("ClassifyChannels.mat", "a_touch_sc", "a_glove_sc", "a_touch_bc", "a_glove_bc", "a_touch_sh", "a_glove_sh", "a_touch_bh", "a_glove_bh");

%% Plot
% Plot precalculated comparison between modalities
% load("ClassifyModalitiesData.mat");
% plot(nan, nan, "linewidth", 2, "color", "b"); % pseudodata for legend
% hold on
% plot(nan, nan, "linewidth", 2, "color", "r");
% plot(nan, nan, "linewidth", 2, "color", "g");
% plot(nan, nan, "linewidth", 2, "color", "k");
% % Actual plotting
% addplot(1-a_touch, 1:50, 'b');
% addplot(1-a_human, 1:50, 'r');
% addplot(1-a_robot, 1:50, 'g');
% addplot(1-a_steel, 1:50, 'k');
% legend({"Human Touch"; "Human Press"; "Robot Press"; "Steel Bolts"});
% legend boxoff

% Plot precalculated comparison between RobotPress electrode configurations
% load("ClassifyModalitiesRobotData.mat");
% addplot(pca_acc, 1:50, 'b');
% hold on
% addplot(opop_acc, 1:50, 'r');
% addplot(opad_acc, 1:50, 'g');
% addplot(adad_acc, 1:50, 'k');
% 
% plot(nan, nan, "linewidth", 2, "color", "m");
% hold on
% plot(nan, nan, "linewidth", 2, "color", "r");
% addplot(1-a_press_H, 1:50, 'm');
% % addplot(1-a_touch_H, 1:50, 'm');
% % hold on
% % addplot(1-a_touch, 1:50, 'b');
% addplot(1-a_human, 1:50, 'r');
% % hold on
% % addplot(1-a_touch_sh, 1:50, 'b');
% % addplot(1-a_touch_sc, 1:50, 'b');
% addplot(1-a_touch_sc, 1:50, 'b');
% legend({"Press Hemisphere"; "Press Membrane"});
% legend boxoff

% plot(nan, nan, "linewidth", 2, "color", "r");
% hold on
% plot(nan, nan, "linewidth", 2, "color", "b");
% plot(nan, nan, "linewidth", 2, "color", "g");
% plot(nan, nan, "linewidth", 2, "color", "m");
% addplot(1-a_touch_sc, 1:50, 'r');
% addplot(1-a_touch_bc, 1:50, 'b');
% addplot(1-a_touch_sh, 1:50, 'g');
% addplot(1-a_touch_bh, 1:50, 'm');
% 
% legend({"Salt Membrane Touch"; "Baking Membrane Touch"; "Salt Hemisphere Touch"; "Baking Hemisphere Touch"});
% legend boxoff

% plot(nan, nan, "linewidth", 2, "color", "r");
% hold on
% plot(nan, nan, "linewidth", 2, "color", "b");
% plot(nan, nan, "linewidth", 2, "color", "g");
% plot(nan, nan, "linewidth", 2, "color", "m");
% addplot(1-a_glove_sc, 1:50, 'r');
% addplot(1-a_glove_bc, 1:50, 'b');
% addplot(1-a_glove_sh, 1:50, 'g');
% addplot(1-a_glove_bh, 1:50, 'm');
% 
% legend({"Salt Membrane Glove"; "Baking Membrane Glove"; "Salt Hemisphere Glove"; "Baking Hemisphere Glove"});
% legend boxoff


plot(nan, nan, "linewidth", 2, "color", "b");
hold on
plot(nan, nan, "linewidth", 2, "color", "r");
plot(nan, nan, "linewidth", 2, "color", "g");
addplot(1-a_touch_H, 1:50, 'r');
addplot(1-a_press_H, 1:50, 'g');
addplot(1-a_glove_H, 1:50, 'b');
legend({"Touch Hemisphere"; "Press Hemisphere"; "Glove Hemisphere"});
legend boxoff

ylabel("Classification Error (%)");
set(gcf, 'position', [415   331   704   420], 'color', 'w'); 
ylim([0 35]);

function accuracies = modalitypredict(modality, ranking)
    % Ranking input is a precalculated vector or leave blank for pca
    quantities = 1:50;
    repetitions = 50;

    inputdata = modality.rms10k(); % use RMS data only (ie no phase)
    labels = modality.eventlabels;
    boundaries = modality.eventboundaries;
    
    outputdata(size(inputdata, 1)) = "O";
    
    for i = 1:length(outputdata)
        outputdata(i) = "O";
    end
    
    for i = 1:size(labels, 1)
        for j = 1:boundaries(i,2)-boundaries(i,1)+1
            outputdata(boundaries(i,1)+j-1) = labels(i);
        end
    end
    
    % Do not consider the frames during which a transition occurs
    cleans = find(~ismember(1:length(outputdata), boundaries));
    inputdata = inputdata(cleans, :);
    outputdata = outputdata(cleans);
    
    accuracies = zeros([length(quantities), repetitions]);
    
    % Use PCA ranking if no other has been given
    if nargin == 1
        coeff = pca(inputdata);
        [~,ranking] = sort(coeff(:,1), 'descend');
    end
    % If another ranking has been given, truncate quantities to match its
    % length
    if length(ranking) < length(quantities)
        quantities = quantities(1:length(ranking));
    end
    
    % Doing the actual work: feed data to classifier and record validation
    % accuracy
    for i = 1:length(quantities)
        quantities(i)
        for j = 1:repetitions
            [~, validationAccuracy] = trainClassifier(inputdata(:, ranking(1:quantities(i))), outputdata);
            accuracies(i,j) = validationAccuracy;
        end
    end
end

function addplot(errors, quantity, col)
    errors = errors*100;
    plot(quantity, mean(errors, 2));
    
    x2 = [quantity, fliplr(quantity)];
    inBetween = [mean(errors.')-std(errors.'),...
        fliplr(mean(errors.')+std(errors.'))];
    fill(x2, inBetween, col, 'linestyle', 'none', 'FaceAlpha', 0.5);
    
    hold on
    plot(quantity, mean(errors, 2), 'linewidth', 2, 'color', 'k');
    box off
    set(gca, 'linewidth', 2, 'fontsize', 15);
    % xlim([0 928]);
    xlabel("Number of Channels");

end