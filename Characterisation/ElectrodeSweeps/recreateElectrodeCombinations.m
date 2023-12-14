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