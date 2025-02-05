s = serialport("COM18",115200, "Timeout", 600);

n = 5;

alldata = zeros([n, 192]);
line = s.readline();

for i = 1:n
    tic
    i
    line = s.readline();
    line = char(line);
    line = str2double(split(line(17:end-1), ","));
    alldata(i, :) = line(1:192).';
    toc
end

clear s
