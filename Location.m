classdef Location
    properties
        coords
        Rep1
        Rep2
        Rep3
    end

    methods
        function obj = Location(filestring, coords)
            obj.coords = coords;
            obj.Rep1 = Repetition(filestring+"_"+"1.txt");
            obj.Rep2 = Repetition(filestring+"_"+"2.txt");
            obj.Rep3 = Repetition(filestring+"_"+"3.txt");
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end