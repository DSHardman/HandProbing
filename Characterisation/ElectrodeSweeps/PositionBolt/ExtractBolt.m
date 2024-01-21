n = 5000;

%% Extract Positions
% times(n) = datetime();
% positions = zeros([n, 2]);
% 
% for i = 1:n
%     line = char(readlines("responses/"+string(i-1)+".txt"));
%     times(i) = datetime(line(1:19), "InputFormat","yyyy-MM-dd HH-mm-ss");
%     both = split(line(21:end), " ");
%     positions(i, :) = [double(string(cell2mat(both(1)))) double(string(cell2mat(both(2))))];
% end

%% Extract Responses
lines = readlines("MoveBolt");
lines = lines(6:end-2);

responsetimes(length(lines)) = datetime();
responses = zeros([length(lines), 3360]);

for i = 1:length(lines)
    if mod(i,100) == 0
        i
    end
    line = char(lines(i));
    responsetimes(i) = datetime(line(2:20), "InputFormat","yyyy-MM-dd HH:mm:ss");
    responses(i, :) = double(string(cell2mat(split(line(27:end-2), ", ")))).';

end