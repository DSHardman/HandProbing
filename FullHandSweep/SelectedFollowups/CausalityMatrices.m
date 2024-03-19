data = reading.rmsanalytic();

subplot(3,2,1);
plotmatrix("Thumb", data, allstimulations);
subplot(3,2,2);
plotmatrix("Full Grasp", data, allstimulations);
subplot(3,2,3);
plotmatrix("Middle Finger", data, allstimulations);
subplot(3,2,4);
plotmatrix("Finger Squeeze", data, allstimulations);
subplot(3,2,5);
plotmatrix("Ruler Base", data, allstimulations);
subplot(3,2,6);
plotmatrix("Nothing", data, allstimulations);

plot(mean(data(1:120, 2037:2057).'))

function plotmatrix(searchstring, data, allstimulations)
    response = zeros([1, 2784]);
    for i = 1:59
        if allstimulations(i) == searchstring
            response = response + mean(data(((i-1)*10)+6:((i-1)*10)+9, :)) -...
                mean(data(((i-1)*10)+1:((i-1)*10)+4, :));
        end
    end
    heatmap(reshape(response, [87, 32]));
    grid off
    colormap parula
    clim([-4e4 4e4]);
    colorbar off
end

function plotpcamatrix(searchstring, data, allstimulations)
    response = [];
    for i = 1:59
        if allstimulations(i) == searchstring
            response = [response; data(((i-1)*10)+1:((i-1)*10)+9, :)];
        end
    end
    [coeff,~,~,~,~,~] = pca(response);
    heatmap(reshape(coeff(:,1), [32, 87]));
    grid off
    % colormap parula
    % clim([-4e4 4e4]);
    % colorbar off
end
