centres = [-0.01 -0.01; 0 0.02; 0.02 -0.01];
radii = [0.005; 0.005; 0.005];

testresponses = [];
testpositions = [];

for i = 1:5000
    for j = 1:3
        if incircle(centres(j,:), radii(j), positions(i,:))
            testresponses = [testresponses; deltaresponses(i,:)];
            testpositions = [testpositions; positions(i, :)];
            break
        end
    end

end

function outputbool = incircle(centre, radius, point)
    outputbool =  rssq(point-centre) < radius;
end