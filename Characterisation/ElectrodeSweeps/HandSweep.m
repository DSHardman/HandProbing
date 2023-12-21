classdef HandSweep
    % Stores experimental recordings from 5 sets of all permutations of 8 electrodes
    % (over 32 electrodes) at 3 frequencies (10kHz, 50kHz, 100kHz), with error

    properties
        times % in seconds
        data % raw data - matrix with width 10080
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
            dataout = obj.data(:, 1+((set-1)*10080):1679+((set-1)*10080));
        end

        function dataout = phase10k(obj, set)
            dataout = obj.data(:, 1680+((set-1)*10080):3358+((set-1)*10080));
        end

        function dataout = rms50k(obj, set)
            dataout = obj.data(:, 3359+((set-1)*10080):5037+((set-1)*10080));
        end

        function dataout = phase50k(obj, set)
            dataout = obj.data(:, 5038+((set-1)*10080):6716+((set-1)*10080));
        end

        function dataout = rms100k(obj, set)
            dataout = obj.data(:, 6717+((set-1)*10080):8395+((set-1)*10080));
        end

        function dataout = phase100k(obj, set)
            dataout = obj.data(:, 8396+((set-1)*10080):10074+((set-1)*10080));
        end
    end
end