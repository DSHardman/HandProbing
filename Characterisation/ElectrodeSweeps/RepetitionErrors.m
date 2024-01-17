% Plot the differences between electrode pair measurements
% i.e. swapping polarity of injection or measurement pairs

figure();
rmss = pressrobot.rms10k();
rmss = rmss(250,:);
phases = pressrobot.phase10k();
phases = phases(250,:);

rmsvpairs = zeros([1679,2]);
phasevpairs = zeros([1679,2]);
rmsipairs = zeros([1679,2]);
phaseipairs = zeros([1679,2]);

for i = 1:1679
    for j = 1:1679
        if comparemeasured(i,j, electrodes)==-1 && compareinjections(i,j, electrodes)==1
            rmsvpairs(i,:) = rmss([i j]).';
            phasevpairs(i,:) = phases([i j]).';
        elseif comparemeasured(i,j, electrodes)==1 && compareinjections(i,j, electrodes)==-1
            rmsipairs(i,:) = rmss([i j]).';
            phaseipairs(i,:) = phases([i j]).';
        end
    end
end

% subplot(1,2,1);
% plot(rmsvpairs(:,1)-mean(rmsvpairs(:,1)));
% hold on
% plot(rmsvpairs(:,2)-mean(rmsvpairs(:,2)));
% plot(rmsvpairs(:,1)-rmsvpairs(:,2), 'color', 'k');
% legend({"Original"; "Voltage Swapped"; "Difference"})
% title("Voltage Swaps");
% 
% subplot(1,2,2);
% plot(rmsipairs(:,1)-mean(rmsipairs(:,1)));
% hold on
% plot(rmsipairs(:,2)-mean(rmsipairs(:,2)));
% plot(rmsipairs(:,1)-rmsipairs(:,2), 'color', 'k');
% legend({"Original"; "Voltage Swapped"; "Difference"})
% title("Current Swaps");
% set(gcf, 'color', 'w');

plot(rmsvpairs(:,1)-rmsvpairs(:,2));
hold on
plot(rmsvpairs(:,1)-rmsvpairs(:,2)-bolterrors, 'color', 'k');
legend({"Error"; "Error minus emptysteelbolt"});
set(gcf, 'color', 'w');

% errors = rmsvpairs(:,1)-rmsvpairs(:,2);
% heatmap(reshape([errors; NaN], [30, 56]).');


function output = comparemeasured(elec1, elec2, electrodes)
    % 1 if identical measured, -1 if opposite, 0 otherwise
    if electrodes(elec1,3)==electrodes(elec2,3) && electrodes(elec1,4)==electrodes(elec2,4)
        output = 1;
    elseif electrodes(elec1,4)==electrodes(elec2,3) && electrodes(elec1,3)==electrodes(elec2,4)
        output = -1;
    else
        output = 0;
    end
end

function output = compareinjections(elec1, elec2, electrodes)
    % 1 if identical injection, -1 if opposite, 0 otherwise
    if electrodes(elec1,1)==electrodes(elec2,1) && electrodes(elec1,2)==electrodes(elec2,2)
        output = 1;
    elseif electrodes(elec1,2)==electrodes(elec2,1) && electrodes(elec1,1)==electrodes(elec2,2)
        output = -1;
    else
        output = 0;
    end
end