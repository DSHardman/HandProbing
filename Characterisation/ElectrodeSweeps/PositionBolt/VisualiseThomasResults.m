% comb3 = [comb3; 1748];

relpos = zeros([3358, 1]);

for i = 1:3358
    relpos(i) = find(comb3==i);
end


heatmap(reshape([relpos(1:1679); NaN; relpos(1680:end); NaN], [30, 112]).');