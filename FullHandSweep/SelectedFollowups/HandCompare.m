classdef HandCompare
    % Storage of data from comparisons of selected combinations to analytic

    properties
        alldata
        times
    end

    methods
        function obj = HandCompare(alldata, times)
            obj.alldata = alldata;
            obj.times = times;
        end

        function rms = rmsall(obj)
            rms = obj.alldata(:, 1:2:end-4);
        end

        function phase = phaseall(obj)
            phase = obj.alldata(:, 2:2:end-4);
        end

        function rms = rmsselected(obj)
            rms = obj.alldata(:, 1:2:2784*2);
        end

        function phase = phaseselected(obj)
            phase = obj.alldata(:, 2:2:2784*2);
        end

        function rms = rmsopop(obj)
            rms = obj.alldata(:, 2784*2+1:2:(2784+960)*2);
        end

        function phase = phaseopop(obj)
            phase = obj.alldata(:, 2784*2+2:2:(2784+960)*2);
        end

        function rms = rmsopad(obj)
            rms = obj.alldata(:, (2784+960)*2+1:2:(2784+960+896)*2);
        end

        function phase = phaseopad(obj)
            phase = obj.alldata(:, (2784+960)*2+2:2:(2784+960+896)*2);
        end

        function rms = rmsadad(obj)
            rms = obj.alldata(:, (2784+960+896)*2+1:2:(2784+960+896+928)*2);
        end

        function phase = phaseadad(obj)
            phase = obj.alldata(:, (2784+960+896)*2+2:2:(2784+960+896+928)*2);
        end
    end
end