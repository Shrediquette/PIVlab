function update_calibration_buttons(handles)
% Enables the buttons of the panels "Camera calibration" and "Image rectification" in the order of
% the work flow: a button is only enabled when the data it needs exists (target images, camera
% parameters, rectification target image). Called by gui.update_dependent_controls, by
% gui.toolsavailable(1) and by the callbacks that load or clear calibration data.
if nargin < 1
    handles = gui.gethand;
end
if ~isfield(handles, 'calib_estimateparams') || ~isfield(handles, 'rect_show_cam_position')
    return % UI not built yet
end
has_targets = ~isempty(gui.retr('cam_selected_target_images'));
has_params = ~isempty(gui.retr('cameraParams'));
has_stats = ~isempty(gui.retr('cameraStats'));
has_rect_image = ~isempty(gui.retr('cam_selected_rectification_image'));
has_stereo_calib = isequal(gui.retr('stereomode'), 1) && ~isempty(gui.retr('stereo_calib'));

%% Camera calibration
enable(handles.calib_estimateparams, has_targets);
enable(handles.calib_clearparams, has_targets || has_params);
enable([handles.calib_saveparams handles.calib_showdistortion handles.calib_viewtype], has_params);
enable(handles.calib_showcams, has_params && has_targets);
enable(handles.calib_showreproject, has_params && has_targets && has_stats);
% a ticked checkbox stays enabled, so that it can be switched off
enable(handles.calib_usecalibration, has_params || handles.calib_usecalibration.Value == 1);

%% Image rectification
enable(handles.rect_load_imgs, has_params);
enable([handles.rect_show_points handles.rect_show_cam_position handles.calib_upscale], has_params && has_rect_image);
enable(handles.rect_show_rectified, (has_params && has_rect_image) || has_stereo_calib);
enable(handles.calib_userectification, (has_params && has_rect_image) || handles.calib_userectification.Value == 1);
end

function enable(h, tf)
if tf
    set(h, 'Enable', 'on');
else
    set(h, 'Enable', 'off');
end
end
