times = [0 0.5 1 1.5 22.5 23 23.5 24 24.5 25 25.5 26 42 44.5 46 49 68.5 74 90.5 93 96];
meas = [235 231 236 239 267 203 245 248 250 253 257 261 295 280 253 262 209 197 294 285 312;
    227 226 230 233 258 206 235 240 233 247 251 243 303 287 272 285 218 211 308 299 328;
    277 249 279 285 318 273 285 286 288 291 294 296 323 306 290 302 218 215 305 311 333;
    207 215 209 214 241 202 217 214 212 209 207 207 160 150 144 143 89 93 131 132 148;
    210 210 213 218 248 212 228 229 232 232 234 237 263 244 236 248 185 185 278 278 311;
    273 274 277 283 318 221 266 258 245 238 220 225 133 116 111 108 56 56 76 79 87];

temps = [20 20 21 20 22 22 21 22 22 21 21 21 19 20 23 22 23 22 20 21 21];
hums = [58 57 58 53 50 51 49 47 45 47 46 46 48 46 42 44 48 51 36 32 30];

% temporary testing
% times = times(6:end);
% meas = meas(:, 6:end);
% temps = temps(6:end);
% hums = hums(6:end);


clf

for i = 1:6
    subplot(2,1,1);
    plot(times, meas(i,:), 'linewidth', 2);
    hold on
end
legend({"1"; "2"; "3"; "4"; "5"; "6"}, 'orientation' ,'horizontal', 'location', 'n');
legend boxoff
set(gca, 'linewidth', 2, 'fontsize', 15);
ylabel("Resistance (k\Omega)");
xlabel("Time (h)");
box off
ylim([0 500]);

set(gcf, 'position', [488   154   560   604], 'color', 'w');

subplot(2,1,2)
yyaxis left
plot(times, hums, 'linewidth', 2);
set(gca, 'YDir', 'reverse');
ylim([25 65]);
set(gca, 'linewidth', 2, 'fontsize', 15);
ylabel("Humdity (%)");

yyaxis right
plot(times, temps, 'linewidth', 2);
ylim([17 26]);
set(gca, 'linewidth', 2, 'fontsize', 15);
ylabel("Temperature (^oC)");
xlabel("Time (h)");
box off

% plot(times, meas(i,:) +60*hums.*meas(i,:));
% hold on