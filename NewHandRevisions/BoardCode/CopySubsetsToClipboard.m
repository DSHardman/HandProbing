order = [];
for src = 1:8
    for sink = 1:8
        if sink ~= src
            for vp = 1:8
                if vp ~= src && vp ~= sink
                    for vn = 1:8
                        if vn ~= src && vn ~= sink && vn ~= vp
                            order = [order; src sink vp vn];
                        end
                    end
                end
            end
        end
    end
end

data = "";

electrodes = [7 5 3 1 31 29 27 25];
for i = 1:length(order)
    data = data + string(electrodes(order(i, 1))) + ", " + ...
        string(electrodes(order(i, 2))) + ", " + ...
        string(electrodes(order(i, 3))) + ", " + ...
        string(electrodes(order(i, 4))) + ", ";
end
electrodes = [9 11 13 15 17 19 21 23];
for i = 1:length(order)
    data = data + string(electrodes(order(i, 1))) + ", " + ...
        string(electrodes(order(i, 2))) + ", " + ...
        string(electrodes(order(i, 3))) + ", " + ...
        string(electrodes(order(i, 4))) + ", ";
end
data = char(data);
data = data(1:end-2); % Remove final comma

clipboard('copy', string(data));
pause();

data = "";
electrodes = [1 5 9 13 17 21 25 29];
for i = 1:length(order)
    data = data + string(electrodes(order(i, 1))) + ", " + ...
        string(electrodes(order(i, 2))) + ", " + ...
        string(electrodes(order(i, 3))) + ", " + ...
        string(electrodes(order(i, 4))) + ", ";
end
data = char(data);
data = data(1:end-2); % Remove final comma

clipboard('copy', string(data));