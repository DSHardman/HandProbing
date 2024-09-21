% % No inclusion: homogeneous data
% homogeneous = idealresponse(NaN, NaN, 0, NaN);
% save("homogeneous.mat", "homogeneous");
% 
% % Generate x y positions within circle
% positions = [];
% signal_strength = 0.3;
% % for temperature = -50:5:50
% temperature = 0;
%     for x = -1:0.02:1
%         for y = -1:0.02:1
%             if x^2 + y^2 <= 1
%                 positions = [positions; x y temperature signal_strength];
%             end
%         end
%     end
% % end
% 
% save("positions.mat", "positions");

% Run EIDORS forward solver for each function and add to measurements
positionmeasurements = zeros([size(positions, 1), 1680]);
for i = 5001:size(positions, 1)
    i
    allmeasurements = idealresponse(positions(i, 1), positions(i, 2), positions(i, 3), positions(i, 4));
    positionmeasurements(i, :) = allmeasurements.';
    if mod(i, 1000) == 0
        save("measurements.mat", "positionmeasurements");
    end
end

save("measurements.mat", "positionmeasurements");
            
function allmeasurements = idealresponse(x, y, temperature, signal_strength)

    % signal_strength between 0 (weakest) & 1 (strongest)
    % temperature between -50 (coldest) & 50 (hottest, highest conductivity)
    % temperature of 0 has no change from homogeneous state
    temp_effect = -0.5*(cos((temperature+50)*pi/100));

    % Conductivity levels: can be changed
    factor1 = 1 + temp_effect; % Originally 1000
    factor2 = -signal_strength; % Originally -950
    
    % 2D Model
    imdl= mk_common_model('d2d1c',8);
    
    % Create an homogeneous image
    img_1 = mk_image(imdl);
    
    % Add a circular inclusion at location [x y]
    img_v = img_1;
    if ~isnan(x)
        select_fcn = inline('(x+'+string(-x)+').^2+(y+'+string(-y)+').^2<0.15^2','x','y','z');
        img_v.elem_data = factor1 + factor2*elem_select(img_v.fwd_model, select_fcn);
    else
        select_fcn = inline('(x).^2+(y).^2<0.15^2','x','y','z');
        img_v.elem_data = factor1 + 0*elem_select(img_v.fwd_model, select_fcn);
    end

    PLANE= [inf,inf,0]; % show voltages on this slice
    
    % Run through all tetrapolar combinations in same order as experiments
    allmeasurements = [];
    for src = 1:8
        for sink = 1:8
            if sink ~= src
                % Set injection pattern
                injections = [src; sink];
                stimmatrix = zeros([8 1]);
                stimmatrix(src) = 0.1;
                stimmatrix(sink) = -0.1;
                img_v.fwd_model.stimulation(1).stim_pattern = sparse(stimmatrix);
    
                measmatrix = [];
                for vp = 1:8
                    if vp ~= injections(1) && vp ~= injections(2)
                        for vn = 1:8
                            if vn ~= injections(1) && vn ~= injections(2) && vn ~= vp
                                % Add measurement pattern
                                measurement = zeros([1 8]);
                                measurement(vp) = 1;
                                measurement(vn) = -1;
                                measmatrix = [measmatrix; measurement];
                            end
                        end
                    end
                end
                img_v.fwd_model.stimulation(1).meas_pattern = sparse(measmatrix);
                img_v.fwd_model.stimulation = img_v.fwd_model.stimulation(1);
                
                % Run forward solver
                vh = fwd_solve(img_v);
                allmeasurements = [allmeasurements; vh.meas];
            end
        end
    end
end