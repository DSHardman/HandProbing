lines = readlines("temperatures.log");
lines = lines(3:end-1); % remove incomplete data

responses = zeros([length(lines), 32]);
times = zeros([length(lines), 1]);

for i = 1:length(lines)
    line = char(lines(i));
    time = datetime(line(2:24));
    if i == 1
        time0 = datetime(time);
    end

    line = line(42:end-1);
    line = split(line, ',');

    for j = 1:32
        responses(i, j) = str2double(line{j});
    end
    times(i) = seconds(time-time0);
end

