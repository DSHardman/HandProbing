electrodes = [];
for src = 1:8
    for sink = 1:8
        if sink ~= src
            for vp = 1:8
                if vp ~= src && vp ~= sink
                    for vn = 1:8
                        if vn ~= src && vn ~= sink && vn ~= vp
                            electrodes = [electrodes; src sink vp vn];
                        end
                    end
                end
            end
        end
    end
end

% Recreate off-by-one error
electrodes = electrodes(1:end-1, :);

%% Find analytic indices, including redundancies
targets = [0 0 0 0];

oppoppinds = [];
for i = 1:8
    targets(1) = i;
    targets(2) = mod(i+4-1, 8)+1;
    for j = 1:8
        if j~=targets(1) && j~=targets(2) && mod(j+4-1, 8)+1~=targets(1) && mod(j+4-1, 8)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+4-1, 8)+1;
            oppoppinds = [oppoppinds; find(ismember(electrodes,targets,'rows'))];
        end
    end
end

oppadinds = [];
for i = 1:8
    targets(1) = i;
    targets(2) = mod(i+4-1, 8)+1;
    for j = 1:8
        if j~=targets(1) && j~=targets(2) && mod(j+1-1, 8)+1~=targets(1) && mod(j+1-1, 8)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+1-1, 8)+1;
            oppadinds = [oppadinds; find(ismember(electrodes,targets,'rows'))];
        end
    end
end

adadinds = [];
for i = 1:8
    targets(1) = i;
    targets(2) = mod(i+1-1, 8)+1;
    for j = 1:8
        if j~=targets(1) && j~=targets(2) && mod(j+1-1, 8)+1~=targets(1) && mod(j+1-1, 8)+1~=targets(2)
            targets(3) = j;
            targets(4) = mod(j+1-1, 8)+1;
            adadinds = [adadinds; find(ismember(electrodes,targets,'rows'))];
        end
    end
end

%% Find analytic indices, NOT including redundancies
% targets = [0 0 0 0];
% 
% Noppoppinds = [];
% for i = 1:4
%     targets(1) = i;
%     targets(2) = mod(i+4-1, 8)+1;
%     for j = 1:4
%         if j~=targets(1) && j~=targets(2) && mod(j+4-1, 8)+1~=targets(1) && mod(j+4-1, 8)+1~=targets(2)
%             targets(3) = j;
%             targets(4) = mod(j+4-1, 8)+1;
%             Noppoppinds = [Noppoppinds; find(ismember(electrodes,targets,'rows'))];
%         end
%     end
% end
% 
% Noppadinds = [];
% for i = 1:4
%     targets(1) = i;
%     targets(2) = mod(i+4-1, 8)+1;
%     for j = 1:8
%         if j~=targets(1) && j~=targets(2) && mod(j+1-1, 8)+1~=targets(1) && mod(j+1-1, 8)+1~=targets(2)
%             targets(3) = j;
%             targets(4) = mod(j+1-1, 8)+1;
%             Noppadinds = [Noppadinds; find(ismember(electrodes,targets,'rows'))];
%         end
%     end
% end
% 
% Nadadinds = [];
% for i = 1:7
%     targets(1) = i;
%     targets(2) = mod(i+1-1, 8)+1;
%     for j = 1:8
%         if j~=targets(1) && j~=targets(2) && mod(j+1-1, 8)+1~=targets(1) && mod(j+1-1, 8)+1~=targets(2)
%             targets(3) = j;
%             targets(4) = mod(j+1-1, 8)+1;
%             Nadadinds = [Nadadinds; find(ismember(electrodes,targets,'rows'))];
%         end
%     end
% end
