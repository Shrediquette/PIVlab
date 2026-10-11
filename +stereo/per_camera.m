function per_camera(action)
%PER_CAMERA Run a PIV analysis or vector validation step for camera 1 and camera 2, then reconstruct U, V, W.
%   stereo.per_camera(action)
%   action  'analyze_all'     ANALYZE (all frames)
%           'analyze_current' analyze the current frame
%           'filter_all'      vector validation, all frames
%           'filter_current'  vector validation, current frame
%           'restore_all'     undo the validation
% The normal 2D routine runs for each camera on its own images (rectified, disparity-corrected), with its
% own masks and background images and the settings of both cameras. The 2D result of each camera is
% per-camera data ('stereo_result', stereo.camera_data_keys); afterwards stereo.update_result reconstructs
% the three components: U, V in the result list of the GUI, W in gui.retr('stereo_vel').
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
analyze = any(strcmp(action, {'analyze_all', 'analyze_current'}));
if analyze
    if isempty(gui.retr('stereo_disparity'))
        if ~batch
            gui.custom_msgbox('msg', hgui, 'Stereo-PIV', ['The disparity correction is measured first, with the settings ' ...
                'of the Stereo-PIV panel.'], 'modal', {'OK'}, 'OK');
        end
        stereo.measure_disparity_Callback;
        if isempty(gui.retr('stereo_disparity'))
            return
        end
    end
end
active = gui.retr('stereo_active_camera');
gui.put('stereo_camera_loop', 1);
cancelled = false;
try
    for k = 1:2
        stereo.switch_camera(k);
        gui.put('resultslist', gui.retr('stereo_result'));
        switch action
            case 'analyze_all'
                piv.AnalyzeAll_Callback;
            case 'analyze_current'
                piv.AnalyzeSingle_Callback;
            case 'filter_all'
                validate.apply_filter_all_Callback;
            case 'filter_current'
                validate.apply_filter_current_Callback;
            case 'restore_all'
                validate.restore_all_Callback;
        end
        gui.put('stereo_result', gui.retr('resultslist'));
        if analyze && isequal(gui.retr('cancel'), 1)
            cancelled = true;
            break
        end
    end
catch err
    gui.put('stereo_camera_loop', 0);
    rethrow(err)
end
gui.put('stereo_camera_loop', 0);
stereo.switch_camera(active);
if cancelled
    gui.put('resultslist', []);
    gui.put('stereo_vel', []);
else
    stereo.update_result;
end
gui.sliderdisp(gui.retr('pivlab_axis'));
end
