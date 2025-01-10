%% Responses
% lines = readlines("Batch4/Batch4");
lines = readlines("SinglesHumanB");
lines = lines(3:end-1); % 5 for SinglesHumanA, 9 for DoublesHumanB, 3 otherwise
times(length(lines)) = datetime();
responses = zeros([length(lines), 3360]);
for i = 1:length(lines)
    line = char(lines(i));
    times(i) = datetime(line(2:24));
    responses(i, :) = str2double(split(line(27:end-2), ", ")).';
end

%% If extracting from SinglesHumanB
singleresponses = zeros([30 3360]);
for i = 1:30
    singleresponses(i, :) = mean(responses((6*i)-1:6*i, :)) - mean(responses((6*i)-4:(6*i)-3, :));
end

%% If extracting from DoublesHumanB
doubleresponses = zeros([11 3360]);
for i = 1:11
    doubleresponses(i, :) = mean(responses((6*i)-2:(6*i)-1, :)) - mean(responses((6*i)-5:(6*i)-4, :));
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