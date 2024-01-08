load("Elipse.mat");
load("lookup192.mat");
load("PrelimExtract.mat");
lookup = lookup + 1;
%elipse16 = elipse(1:2:end,:);

n = 1;

for n = 1:192
    subplot(1,2,1);
    scatter(elipse(lookup(n,1:2), 1), -elipse(lookup(n,1:2), 2), 20, 'r', 'filled');
    hold on
    scatter(elipse(lookup(n,3:4), 1), -elipse(lookup(n,3:4), 2), 20, 'g', 'filled');
    xlim([0 600]);
    ylim([-600 -50]);
    title(string(n));
    axis equal

    subplot(1,2,2);
    scatter(positions(:,1), positions(:,2), 20, responsedowns(:, n)-responseups(:,n), 'filled');
    colorbar();
    axis equal
    set(gcf, 'position', [188 242 1155 415]);
    accept = ginput(1);
    if accept(1) > 150
        fprintf(string(n));
    end
    clf
end
