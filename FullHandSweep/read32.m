s = serialport("COM8",230400, "Timeout", 600);
% configureCallback(s, "byte", 50000, @testfunc);
% disp(datestr(datetime("now"),'HH:MM:SS:FFF'));

alldata = zeros(5, 2*863040+4);

for i = 1:5
    tic
    data = read(s, (2*863040+4), "int16");
    toc
    alldata(i, :) = data;
end

% data = read(s, (86300), "int16");

clear s

subplot(2,1,1);
plot(data(1:2:end));

subplot(2,1,2);
plot(data(2:2:end));
% assert(length(find(data(1:4)==-1))==4);
% data = reshape(data(5:end), [6, 3400]);
