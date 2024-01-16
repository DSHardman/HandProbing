 % warning('off','last')

testdata = touchsingle.rms10k();

numcombs = [50 100 200 300 400 500 600 1000 1500 1679];
numreps = 1000;
numclusts = 4;

sil_vals = zeros([numreps, length(numcombs)]);

for i = 1:length(numcombs)
    i
    for j = 1:numreps
        inds = randperm(size(testdata, 2), numcombs(i));
        pcadata = testdata(:, inds);
        [coeff,score,latent,tsquared,explained, mu] = pca(pcadata);
        idx = kmeans(score(:, 1:2),numclusts);
        s = silhouette(score(:, 1:2), idx);
        sil_vals(j,i) = mean(s);
    end
end

plot(numcombs, mean(sil_vals));