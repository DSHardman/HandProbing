%% Responses
% lines = readlines("Batch4/Batch4");
lines = readlines("SinglesHumanA");
lines = lines(5:end-1); % 5 for SinglesHumanA, 3 otherwise
times(length(lines)) = datetime();
responses = zeros([length(lines), 3360]);
for i = 1:length(lines)
    line = char(lines(i));
    times(i) = datetime(line(2:24));
    responses(i, :) = str2double(split(line(27:end-2), ", ")).';
end

%% If extracting from SinglesHuman
singleresponses = zeros([30 3360]);
for i = 1:30
    singleresponses(i, :) = mean(responses((6*i)-1:6*i, :)) - mean(responses((6*i)-4:(6*i)-3, :));
end

%% Presses
presstimes(630) = datetime();
patterns = zeros([630, 6]);
for i = 1:630
    i
    line = readlines("Batch4/"+string(i-1)+".txt");
    line = char(line);
    presstimes(i) = datetime(line(1:19), "InputFormat", "uuuu-MM-dd HH-mm-ss");
    for j = 1:6
        patterns(i, j) = str2double(line(20+j));
    end
end