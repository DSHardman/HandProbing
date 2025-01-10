befores = zeros([630, 3360]);
afters = zeros([630, 3360]);

for i = 1:630
    ind = find(times>presstimes(i), 1, "first");
    befores(i, :) = mean(responses(ind-2:ind-1, :));
    afters(i, :) = mean(responses(ind+1:ind+3, :));
end
syncresponses = afters - befores;