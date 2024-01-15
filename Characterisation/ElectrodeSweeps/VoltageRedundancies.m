voltages = zeros(6);
for i = 1:6
    voltages(i,elects(i*5,3)-2) = 0;
    for j = 1:5
        voltages(i,elects((i-1)*5+j, 4)-2) = reads((i-1)*5+j);
    end
end

for i = 1:6
    for j = 1:6
        scatter(j, voltages(i,j)-voltages(i,1));
        hold on
        scatter(j, -voltages(i,j)-voltages(i,1));
    end
end