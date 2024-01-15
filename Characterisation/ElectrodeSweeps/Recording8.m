classdef Recording8
    % Stores experimental recordings from all permutations of 8 electrodes
    % at 3 frequencies (10kHz, 50kHz, 100kHz), with error

    properties
        times % in seconds
        data % raw data - matrix with width 10080
        eventboundaries % start and stop indicies of each event
        eventlabels % Text descriptions of events
    end

    methods
        function obj = Recording8(filename)
            % Constructor - extract files from timestamped teraterm logs

            lines = readlines(filename);
            lines = lines(3:end-2);
        
            timestamps = zeros([length(lines), 1]);
            % data = zeros([length(lines), 10080]);
            data = zeros([length(lines), 10074]);
            for i = 1:length(lines)
                line = char(lines(i));
                if i == 1
                    t0 = datetime(line(2:24));
                else
                    timestamps(i) = seconds(datetime(line(2:24)) - t0);
                end
                linedata = str2double(split(line(27:end-2), ', '));

                % Remove first erroneous datapoint from each 
                data(i, :) = linedata([2:1680 1682:3360 3362:5040 5042:6720 6722:8400 8402:10080]);
            end
            
            obj.times = timestamps;
            obj.data = data;

        end

        function dataout = rms10k(obj)
            dataout = obj.data(:, 1:1679);
        end

        function dataout = phase10k(obj)
            dataout = obj.data(:, 1680:3358);
        end

        function dataout = rms50k(obj)
            dataout = obj.data(:, 3359:5037);
        end

        function dataout = phase50k(obj)
            dataout = obj.data(:, 5038:6716);
        end

        function dataout = rms100k(obj)
            dataout = obj.data(:, 6717:8395);
        end

        function dataout = phase100k(obj)
            dataout = obj.data(:, 8396:10074);
        end

        function outobj = logevents(obj, n)
            plot(obj.rms50k());
            obj.eventboundaries = zeros([n, 2]);
            for i = 1:n
                title(string(i));
                coord = ginput(1);
                obj.eventboundaries(i, 1) = round(coord(1));
                coord = ginput(1);
                obj.eventboundaries(i, 2) = round(coord(1));
            end
            outobj = obj;
        end
    end
end