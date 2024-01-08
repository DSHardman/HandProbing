classdef Repetition
    properties
        rms
        mag
        phase
    end

    methods
        function obj = Repetition(filestring)
            data = readmatrix(filestring);
            data = [zeros(size(data,1), 1) data(:, 2:end-1)];

            obj.rms = zeros(size(data,1), size(data,2)/3);
            obj.mag = zeros(size(data,1), size(data,2)/3);
            obj.phase = zeros(size(data,1), size(data,2)/3);
            for i = 1:size(data,2)/3
                obj.rms(:, i) = data(:, i*3-2);
                obj.mag(:, i) = data(:, i*3-1);
                obj.phase(:, i) = data(:, i*3);
            end
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end