classdef MeasureSetup
    properties
        freq
        type
        locA
        locB
        locC
        locD
        locE
    end

    methods
        function obj = MeasureSetup(freqstring, typestring, folder)
            obj.freq = freqstring;
            obj.type = typestring;
            obj.locA = Location(folder+freqstring+"_"+typestring+"_"+"A", [17 130]);
            obj.locB = Location(folder+freqstring+"_"+typestring+"_"+"B", [45 105]);
            obj.locC = Location(folder+freqstring+"_"+typestring+"_"+"C", [80 180]);
            obj.locD = Location(folder+freqstring+"_"+typestring+"_"+"D", [166 90]);
            obj.locE = Location(folder+freqstring+"_"+typestring+"_"+"E", [100 75]);
        end

        function outputArg = method1(obj,inputArg)
            outputArg = obj.Property1 + inputArg;
        end
    end
end