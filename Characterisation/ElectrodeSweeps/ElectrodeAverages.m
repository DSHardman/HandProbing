recreateElectrodeCombinations

readings = touchsingle.rms50k();

electrodeaverages = zeros([size(readings, 1) 8]);
for i = 1:size(readings, 1)
    for j = 1:8
        total = 0;
        for k = 1:1679
            if any(electrodes(k, :)==j)
                electrodeaverages(i,j) = electrodeaverages(i,j) + readings(i, k);
                total = total + 1;
            end
        end
        electrodeaverages(i,j) = electrodeaverages(i,j)/total;
    end
end

electrodeaverages = electrodeaverages(3:end,:);
electrodeaverages = electrodeaverages - electrodeaverages(1,:);
plot(electrodeaverages);