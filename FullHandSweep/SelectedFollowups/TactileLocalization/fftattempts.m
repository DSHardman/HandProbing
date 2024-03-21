fftratios = zeros([11140, 1]);

% Compare to Sine Wave: not FFT
% comparison = ones([1020, 1]);
% for i = 1:100
%     for j = 1:5
%         comparison((i-1)*10+4+j) = 0;
%     end
% end
% for i = 1:11140
%     % data = normalize(alldata(:, i));
%     fftratios(i) = abs(xcorr(comparison, data, 0));
%     if isnan(fftratios(i))
%         fftratios(i) = 0;
%     end
% end
% 
% [~,ind] = sort(fftratios, 'descend'); ind = ind.';
% 
% overlaps = zeros([11140, 1]);
% for i = 1:11140
%     overlaps(i) = length(unique([rankingall(1:i) ind(1:i)]))/i;
% end
% plot(overlaps);


% FFT
for i = 1:11140
    data = alldata(:, i);
    data = data - mean(data);
    data = abs(fft(data));
    data = abs(fftshift(data));
    L = length(data);
    f = 1/L*(-L/2:L/2-1);
    plot(f,data,"LineWidth",3);

    [~, ind1] = sort(abs(f-0.1), 'ascend');
    [~, ind2] = sort(abs(f-0.2), 'ascend');
    [~, ind3] = sort(abs(f-0.3), 'ascend');

    fftratios(i) = (data(ind1(1))+data(ind3(1)))/data(ind2(1));
    if isnan(fftratios(i))
        fftratios(i) = 0;
    end
end

% Find best performing
[~,ind] = sort(fftratios, 'descend'); ind = ind.';

% How does this ranking compare to F-tests: is there overlap?
overlaps = zeros([11140, 1]);
for i = 1:11140
    overlaps(i) = length(unique([ranking(1:i) ind(1:i)]))/i;
end
plot(overlaps);