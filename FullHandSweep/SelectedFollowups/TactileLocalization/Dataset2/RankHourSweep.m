%% Original
responsemag = zeros([1726080, 1]);

for i = 1:1726080
    responsemag(i) = abs(mean(alldata(6:8, i))-mean(alldata(1:5, i)))+...
        abs(mean(alldata(14:16, i))-mean(alldata(9:13, i)))+...
        abs(mean(alldata(22:24, i))-mean(alldata(17:21, i)));

    responsemag(i) = responsemag(i)/std(alldata(1:24, i));
    if isnan(responsemag(i))
        responsemag(i) = 0;
    end
end

[~,ind] = sort(responsemag, 'descend');
ranking = ind;

%% Alternatively: PCA (if possible)
[coeff,~,~,~,~,~] = pca(alldata);
[~,ranking] = sort(mean(abs(coeff(:,1)), 2), 'descend');