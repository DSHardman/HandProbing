classdef HandSweep
    % Stores experimental recordings from 5 sets of all permutations of 8 electrodes
    % (over 32 electrodes) at 3 frequencies (10kHz, 50kHz, 100kHz), with error

    properties
        times % in seconds
        data % raw data - matrix with width 50400
    end

    methods
        function obj = HandSweep(filename)
            % Constructor - extract files from timestamped teraterm logs

            lines = readlines(filename);
            lines = lines(3:end-1);
        
            timestamps = zeros([length(lines), 1]);
            data = zeros([length(lines), 5*10080]);
            for i = 1:length(lines)
                line = char(lines(i));
                if i == 1
                    t0 = datetime(line(2:24));
                else
                    timestamps(i) = seconds(datetime(line(2:24)) - t0);
                end
                linedata = str2double(split(line(27:end-2), ', '));
                data(i, :) = linedata;
            end
            
            obj.times = timestamps;
            obj.data = data;

        end

        function dataout = rms10k(obj, set)
            dataout = obj.data(:, 1+((set-1)*3360):1680+((set-1)*3360));
        end

        function dataout = phase10k(obj, set)
            dataout = obj.data(:, 1681+((set-1)*3360):3360+((set-1)*3360));
        end

        function dataout = rms50k(obj, set)
            dataout = obj.data(:, 16801+((set-1)*3360):18480+((set-1)*3360));
        end

        function dataout = phase50k(obj, set)
            dataout = obj.data(:, 18481+((set-1)*3360):20160+((set-1)*3360));
        end

        function dataout = rms100k(obj, set)
            dataout = obj.data(:, 33601+((set-1)*3360):35280+((set-1)*3360));
        end

        function dataout = phase100k(obj, set)
            dataout = obj.data(:, 35281+((set-1)*3360):36960+((set-1)*3360));
        end
    end
end