% load("Data/Dataset2/CombinedSet2.mat");
% load("Data/Dataset5/CombinedSet5Cleaned.mat");
load("Data/Dataset6/CombinedSet6.mat");

%% F-Test ranking for x & y positions on front & back
ranking1 = fsrftest(responses, targetpositions(:, 1));
ranking2 = fsrftest(responses, targetpositions(:, 2));
ranking3 = fsrftest(responses, targetpositions(:, 3));
ranking4 = fsrftest(responses, targetpositions(:, 4));

%% Look at activation maps of highest ranked channels

for i = 1:100
    subplot(2,2,1);
    scatter(targetpositions(:,1), targetpositions(:,2), 40, responses(:, ranking1(i)), 'filled');
    title("Front x");
    
    subplot(2,2,2);
    scatter(targetpositions(:,1), targetpositions(:,2), 40, responses(:, ranking2(i)), 'filled');
    title("Front y");
    
    subplot(2,2,3);
    scatter(targetpositions(:,3), targetpositions(:,4), 40, responses(:, ranking3(i)), 'filled');
    title("Back x");
    
    subplot(2,2,4);
    scatter(targetpositions(:,3), targetpositions(:,4), 40, responses(:, ranking4(i)), 'filled');
    title("Back y");

    sgtitle(string(i));
    pause();
end