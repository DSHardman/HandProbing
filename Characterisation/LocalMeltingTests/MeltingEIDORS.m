% Different EIDORS parameters run on melting tests & output as videos

imdl_2d= mk_common_model('b2c', [8, 1]);
% show_fem(imdl_2d.fwd_model);
[stim, meas_select] =  mk_stim_patterns(8,1,'{op}','{ad}', {'no_meas_current'});


imdl_2d.fwd_model.stimulation = stim;
imdl_2d.fwd_model.meas_select = meas_select;


hyperpars = [0.1, 0.03, 0.01, 0.005, 0.001, 0.0005];
clims = [50, 200, 3000, 5000, 20000, 50000];

for i = 1:length(hyperpars)
    imdl_2d.hyperparameter.value = hyperpars(i);
    imdl_2d.solve=       'inv_solve_diff_GN_one_step';
    nextsteps(imdl_2d, responses, string(hyperpars(i)), clims(i));
    i
end

function nextsteps(imdl_2d, responses, filename, lims)
    writerObj = VideoWriter(filename+'.avi');
    writerObj.FrameRate = 10;
    open(writerObj); 
    for i = 11:10:length(responses)
        rec_img= inv_solve(imdl_2d, responses(i-10,:).', responses(i,:).');
        rec_img.calc_colours.clim = lims;
        show_slices(rec_img);
        title(string(i));
        writeVideo(writerObj, getframe(gcf));
    end
    close(writerObj);
end