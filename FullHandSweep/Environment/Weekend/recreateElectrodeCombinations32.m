electrodes = zeros([32*31*30*29, 4]);
n = 1;


for src = 1:32
    for sink = 1:32
        if sink ~= src
            for vp = 1:32
                if vp ~= src && vp ~= sink
                    for vn = 1:32
                        if vn ~= src && vn ~= sink && vn ~= vp
                            electrodes(n, :) = [src sink vp vn];
                            n = n + 1;
                        end
                    end
                end
            end
        end
    end
end

%% Followed by analytic configurations

targets = [0 0 0 0];

n = 1
oppoppinds = zeros([960, 1]);
for i = 1:32
    targets(1) = i
    targets(2) = mod(i+16-1, 32)+1;
    for j = 1:32
        if j~=targets(1) && j~=targets(2) && mod(j+16-1, 32)+1~=targets(1) && mod(j+16-1, 32)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+16-1, 32)+1;
            oppoppinds(n) = find(ismember(electrodes,targets,'rows'));
            n = n + 1;
        end
    end
end

n = 1
oppadinds = zeros([896, 1]);
for i = 1:32
    targets(1) = i
    targets(2) = mod(i+16-1, 32)+1;
    for j = 1:32
        targets(3) = j;
        targets(4) = mod(j+1-1, 32)+1;
        if j~=targets(1) && j~=targets(2) && mod(j+1-1, 32)+1~=targets(1) && mod(j+1-1, 32)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+1-1, 32)+1;
            oppadinds(n) = find(ismember(electrodes,targets,'rows'));
            n = n + 1;
        end
    end
end

n = 1
adadinds = zeros([928, 1]);
for i = 1:32
    targets(1) = i
    targets(2) = mod(i+1-1, 32)+1;
    for j = 1:32
        if j~=targets(1) && j~=targets(2) && mod(j+1-1, 32)+1~=targets(1) && mod(j+1-1, 32)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+1-1, 32)+1;
            adadinds(n) = find(ismember(electrodes,targets,'rows'));
            n = n + 1;
        end
    end
end