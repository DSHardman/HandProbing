n = 5000;

% Extract Positions
times(n) = datetime();
positions = zeros([n, 2]);

for i = 1:n
    line = char(readlines("channelresponses/"+string(i-1)+".txt"));
    times(i) = datetime(line(1:19), "InputFormat","yyyy-MM-dd HH-mm-ss");
    both = split(line(21:end), " ");
    positions(i, :) = [double(string(cell2mat(both(1)))) double(string(cell2mat(both(2))))];
end

% Extract Responses
lines = readlines("channelbolt");
lines = lines(6:end-2);

responsetimes(length(lines)) = datetime();
responses = zeros([length(lines), 3360]);

keepers = [];
for i = 1:length(lines)
    % if mod(i,100) == 0
    %     i
    % end
    line = char(lines(i));
    try
        reading = double(string(cell2mat(split(line(27:end-2), ", ")))).';
        if length(reading) < 3361
            responses(i, :) = [reading zeros([1, 3360-length(reading)])];
            responsetimes(i) = datetime(line(2:20), "InputFormat","yyyy-MM-dd HH:mm:ss");
            keepers = [keepers; i];
        end
    catch
        i
    end

end


responsetimes = responsetimes(keepers);
responses = responses(keepers, :);

%% Different delta attempt (better NN localization)
n = 160;

deltaresponses = zeros([n, size(responses, 2)]);
isindex = zeros([size(responses, 1), 1]);

for i = 1:n
    index = find(responsetimes>times(i), 1);
    deltaresponses(i, :) = responses(index+1, :) -...
        responses(index-2, :);
        % mean(responses(index-9:index+9, :));
    isindex(index) = 1;
end

deltaresponses = deltaresponses(:, [2:1680 1682:end]); % off-by-one error

