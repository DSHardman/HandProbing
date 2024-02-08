calculatefields(1, 30, 2, 1);
calculatefields(1000, -950, 2, 3);
set(gcf, 'color', 'w', 'position', [385   211   684   586]);

function calculatefields(factor1, factor2, n, m)
    % 2D Model
    imdl= mk_common_model('d2d1c',8);
    
    % Create an homogeneous image
    img_1 = mk_image(imdl);
    
    % Add a circular object
    img_v = img_1;
    select_fcn = inline('(x+0.3).^2+(y+0.3).^2<0.2^2','x','y','z');
    img_v.elem_data = factor1 + factor2*elem_select(img_v.fwd_model, select_fcn);
    
    % Visualise FEM
    % show_fem(img_v);
    % axis off; axis equal;
    
    PLANE= [inf,inf,0]; % show voltages on this slice
    
    % Set stimulation pattern
    img_v.fwd_model.stimulation(1).stim_pattern = sparse([1;4],1,[1,-1],8,1);
    img_v.fwd_solve.get_all_meas = 1;
    vh = fwd_solve(img_v);
    
    %% Plot Voltages
    
    % img_volt = rmfield(img_v, 'elem_data');
    % img_volt.node_data = vh.volt(:,1);
    % img_volt.calc_colours.npoints = 128;
    % 
    % show_slices(img_volt,PLANE); axis off; axis equal
    
    %% Plot Current quiver
    subplot(n,2,m);
    img_v.fwd_model.mdl_slice_mapper.npx = 64;
    img_v.fwd_model.mdl_slice_mapper.npy = 64;
    img_v.fwd_model.mdl_slice_mapper.level = PLANE;
    q = show_current(img_v, vh.volt(:,1));
    quiver(q.xp,q.yp, q.xc,q.yc,23, 'k');
    axis tight; axis image; axis off
    ylim([-1 1])
    xlim([-1 1])
    
    %% Plot Equipotentials and Streamlines
    
    subplot(n,2,m+1);
    
    img_v = rmfield(img_v, 'elem_data');
    img_v.node_data = vh.volt(:,1);
    img_v.calc_colours.npoints = 256;
    imgs = calc_slices(img_v,PLANE);
    
    sx = linspace(-.75,.75,40)';
    sy = 0.05 + linspace(-.5,.5,40)';
    hh=streamline(q.xp,q.yp, q.xc, q.yc,sx,sy); set(hh,'Linewidth',1);
    hh=streamline(q.xp,q.yp,-q.xc,-q.yc,sx,sy); set(hh,'Linewidth',1);
    
    pic = shape_library('get','adult_male','pic');
    [x y] = meshgrid( linspace(pic.X(1), pic.X(2),size(imgs,1)), ...
                      linspace(pic.Y(2), pic.Y(1),size(imgs,2)));
    hold on;
    contour(x,y,imgs,61, 'k');

    [x, y] = pol2cart(5*pi/4, 1);
    scatter(x, y, 20, 'r', 'filled');

    [x, y] = pol2cart(4*pi/4, 1);
    scatter(x, y, 20, 'r', 'filled');
    
    hold off; axis off; axis equal;

end