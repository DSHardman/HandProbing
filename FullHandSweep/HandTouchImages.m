%% Test 1

alldata = test1;

lineardata = reshape(alldata.', [8630420, 1]);
alldataformat = reshape([lineardata; zeros([10, 1])], [1726086, 5]).';

inds = find(alldataformat(3,:)==-1);

baseline1 = alldataformat(1, [inds(end)+3:2:end 1:2:inds(1)-1]);
baseline2 = alldataformat(1, [inds(end)+3+1:2:end 1+1:2:inds(1)-1]);

for i = 2:5
    subplot(2,1,1);
    image = reshape((alldataformat(i,[inds(end)+3+1:2:end 1+1:2:inds(1)-1])-baseline2)./(abs(baseline2)+1e-4), [870, 992]);
    imshow(abs(image), [0 1e4]);

    subplot(2,1,2);
    image = reshape((alldataformat(i,[inds(end)+3:2:end 1:2:inds(1)-1])-baseline1)./(abs(baseline1)+1e-4), [870, 992]);
    imshow(abs(image), [0 5]);

    pause();
    % print("Test1"+string(i)+'.png','-dpng');
    clf
end

%% Test 2

alldata = test2;

lineardata = reshape(alldata.', [8630420, 1]);
alldataformat = reshape([lineardata; zeros([10, 1])], [1726086, 5]).';

inds = find(alldataformat(3,:)==-1);

for i = 1:5
    subplot(2,1,1);
    image = reshape((alldataformat(i,[inds(end)+3+1:2:end 1+1:2:inds(1)-1])-baseline2)./(abs(baseline2)+1e-4), [870, 992]);
    imshow(abs(image), [0 1e4]);

    subplot(2,1,2);
    image = reshape((alldataformat(i,[inds(end)+3:2:end 1:2:inds(1)-1])-baseline1)./(abs(baseline1)+1e-4), [870, 992]);
    imshow(abs(image), [0 5]);

    pause();
    % print("Test2"+string(i)+'.png','-dpng');
    clf
end