s = serialport("COM8",230400, "Timeout", 600);
% configureCallback(s, "byte", 50000, @testfunc);
% disp(datestr(datetime("now"),'HH:MM:SS:FFF'));

n = 5;

alldata = zeros(n, 2*863040+4);
times(n) = datetime();

order = [randperm(5) randperm(5)];
fingers = ["Pinky" "Ring" "Middle" "Index" "Thumb"];

test = 1;

for i = 1:n
    i
    tic
    if (mod(i+1,4)==0)
        fprintf("TEST FRAMES: TOUCH " + fingers(order(test))+ "\n\n");
        test = test + 1;
    end
    if (mod(i+3,4)==0)
        fprintf("RELEASE FRAME \n\n");
    end
    data = read(s, (2*863040+4), "int16");
    assert(length(find(data==-1)) == 4); % Fine once passed once: expect this to fail 50% of the time
    toc
    alldata(i, :) = data;
    times(i) = datetime(); % save time at which frame finished collecting
    % save("conditions.mat", "alldata", "times");
end

% data = read(s, (86300), "int16");

clear s

subplot(2,1,1);
plot(data(1:2:end));

subplot(2,1,2);
plot(data(2:2:end));
% assert(length(find(data(1:4)==-1))==4);
% data = reshape(data(5:end), [6, 3400]);
