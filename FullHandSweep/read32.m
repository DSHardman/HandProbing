s = serialport("COM20",230400, "Timeout", 600);
% configureCallback(s, "byte", 50000, @testfunc);
% disp(datestr(datetime("now"),'HH:MM:SS:FFF'));

n = 10;
configs = 5100;

% Let data settle after starting...
for i = 1%:3
    i
    tic
    data = read(s, (2*configs+4), "int16");
    toc
    % data = read(s, (2*863040+4), "int16");
end

alldata = zeros(n, 2*configs+4);
% alldata = zeros(n, 2*863040+4);

times(n) = datetime();

for i = 1:n
    i
    tic
    data = read(s, (2*configs+4), "int16");
    % data = read(s, (2*863040+4), "int16");
    assert(length(find(data==-1)) == 4); % Fine once passed once: expect this to fail 50% of the time
    toc
    alldata(i, :) = data;
    times(i) = datetime(); % save time at which frame finished collecting
    % save("after2personcondition2nd.mat", "alldata", "times");
end

% data = read(s, (86300), "int16");

clear s

subplot(2,1,1);
plot(data(1:2:end));

subplot(2,1,2);
plot(data(2:2:end));
% assert(length(find(data(1:4)==-1))==4);
% data = reshape(data(5:end), [6, 3400]);
