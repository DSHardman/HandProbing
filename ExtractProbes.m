readstring = "Responses/PreliminaryTests/";
n = size(dir([readstring + '*.npy']));
n = floor(n(1)/3);
combs=192;

positions = zeros(n, 2);
responseups = zeros(n, combs);
responsedowns = zeros(n, combs);

for i = 0:n-1
    position = readNPY(readstring + 'position_' + string(i) + '.npy');
    responseup = readNPY(readstring + 'up_' + string(i) + '.npy');
    responsedown = readNPY(readstring + 'down_' + string(i) + '.npy');

    positions(i+1, :) = position;
    responseups(i+1, :) = responseup;
    responsedowns(i+1, :) = responsedown;
end
