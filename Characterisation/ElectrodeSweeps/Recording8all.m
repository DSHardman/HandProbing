classdef Recording8all
    % Stores experimental recordings from all permutations of 8 electrodes
    % at 3 frequencies (10kHz, 50kHz, 100kHz), without error

    properties
        times % in seconds
        data % raw data - matrix with width 10080
    end

    methods
        function obj = Recording8all(filename)
            % Constructor - extract files from timestamped teraterm logs

            lines = readlines(filename);
            lines = lines(3:end-2);
        
            timestamps = zeros([length(lines), 1]);
            data = zeros([length(lines), 10080]);
            for i = 1:length(lines)
                line = char(lines(i));
                if i == 1
                    t0 = datetime(line(2:24));
                else
                    timestamps(i) = seconds(datetime(line(2:24)) - t0);
                end
                linedata = str2double(split(line(27:end-2), ', '));

                % Remove first erroneous datapoint from each 
                data(i, :) = linedata([1:1680 1681:3360 3361:5040 5041:6720 6721:8400 8401:10080]);
            end
            
            obj.times = timestamps;
            obj.data = data;

        end

        function dataout = rms10k(obj)
            dataout = obj.data(:, 1:1680);
        end

        function dataout = phase10k(obj)
            dataout = obj.data(:, 1681:3360);
        end

        function dataout = rms50k(obj)
            dataout = obj.data(:, 3361:5040);
        end

        function dataout = phase50k(obj)
            dataout = obj.data(:, 5041:6720);
        end

        function dataout = rms100k(obj)
            dataout = obj.data(:, 6721:8400);
        end

        function dataout = phase100k(obj)
            dataout = obj.data(:, 8401:10080);
        end
    end
end