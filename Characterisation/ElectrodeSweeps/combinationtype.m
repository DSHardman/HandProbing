function type = combinationtype(electrodes)

    % Positions relative to the first electrode
    pos = [mod(electrodes(2)-electrodes(1), 8)...
        mod(electrodes(3)-electrodes(1), 8)...
        mod(electrodes(4)-electrodes(1), 8)];

    % Get size of gaps
    pos = sort(pos);
    gaps = [pos(1)-1 pos(2)-pos(1)-1 pos(3)-pos(2)-1 8-pos(3)-1];

    type = nan; % Something isn't working if nan is output

    assert(sum(gaps)==4);

    % All cases: see drawings for easier understanding
    if any(gaps==4)
        type = 1; % TYPE 1: 0,0,0,4
    elseif all(gaps==1)
        type = 2; % TYPE 2: 1,1,1,1
    elseif length(find(gaps==2))==2
        inds = find(gaps==2);
        if mod(inds(2)-inds(1),2)==1
            type = 3; % TYPE 3: 0,0,2,2
        elseif inds(2)-inds(1)==2
            type = 4; % TYPE 4: 0,2,0,2
        end
    elseif length(find(gaps==1))==2
        inds = find(gaps==1);
        if mod(inds(2)-inds(1),2)==1
            type = 5; % TYPE 5: 0,1,1,2
        elseif inds(2)-inds(1)==2
            type = 6; % TYPE 6: 0,1,2,1
        end
    elseif length(find(gaps==3))==1
        inds = find(gaps==0);
        if mod(inds(2)-inds(1),2)==1
            type = 7; % TYPE 7: 0,0,1,3
        elseif inds(2)-inds(1)==2
            type = 8; % TYPE 8: 0,1,0,3
        end
    end

    assert(~isnan(type));
        
end