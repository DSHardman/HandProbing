function [spectra, timestamps] = ExtractSpectra(filename)
    lines = readlines(filename);
    lines = lines(3:end-2);

    startingpoints = [];
    for i = 1:length(lines)-14
        line = char(lines(i));
        linedata = str2double(split(line(38:end-2), '; '));
        if linedata(1) == 200
            line = char(lines(i+14));
            linedata = str2double(split(line(38:end-2), '; '));
            if length(linedata) == 2
                if linedata(1) == 70000
                    if isempty(startingpoints)
                        t0 = datetime(line(2:24));
                    end
                    startingpoints = [startingpoints; i];
                end
            end
        end
    end

    spectra = zeros([length(startingpoints), 15]);
    timestamps = zeros([length(startingpoints), 1]);

    for j = 1:length(startingpoints)
        for k = 1:15
            line = char(lines(startingpoints(j)+k-1));
            if k == 1
                timestamps(j) = seconds(datetime(line(2:24)) - t0);
            end
            linedata = str2double(split(line(38:end-2), '; '));
            if length(linedata)==2
                spectra(j, k) = linedata(2);
            else
                spectra(j, k) = 0;
            end
        end
    end
end