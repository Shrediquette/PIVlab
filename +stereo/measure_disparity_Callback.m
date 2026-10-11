function measure_disparity_Callback(~, ~, ~)
%MEASURE_DISPARITY_CALLBACK "Measure disparity" (Stereo-PIV panel).
% Correlates the A images of camera 1 and camera 2 (rectified, minimum-intensity background removed,
% image pre-processing of the GUI) and fits a smooth model (stereo.measure_disparity). Afterwards both
% cameras show disparity-corrected images (stereo.update_maps); an automatic region of interest is
% adapted to the corrected overlap. Results are reset (they were computed without this correction).
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
calib = gui.retr('stereo_calib');
if ~isequal(gui.retr('stereomode'), 1) || isempty(calib)
    gui.custom_msgbox('error', hgui, 'Stereo-PIV', 'Compute the stereo calibration first.', 'modal');
    return
end
handles = gui.gethand;
imgs = stereo.gui_image_sets(handles);
st = stereo.settings_from_gui(handles);
% minimum backgrounds: the ones of an earlier measurement, or the camera backgrounds if background
% subtraction is "minimum intensity" (raw camera images in stereo mode), else computed now
backgrounds = {};
old = gui.retr('stereo_disparity');
state = gui.retr('stereo_cam_state');
if ~isempty(old) && isfield(old, 'background') && ~isempty(old.background{1}) && ~isempty(old.background{2})
    backgrounds = old.background;
elseif get(handles.bg_subtract, 'Value') == 3 && ~isempty(state{1}.bg_img_A) && ~isempty(state{2}.bg_img_A)
    backgrounds = {struct('A', state{1}.bg_img_A, 'B', []), struct('A', state{2}.bg_img_A, 'B', [])};
end
gui.toolsavailable(0, 'Measuring the disparity...'); drawnow
% progress and remaining time as in the PIV analysis: in the Stereo-PIV panel, or in the ANALYZE panel when
% ANALYZE measures the disparity first (stereo.per_camera)
if strcmp(get(handles.multip30, 'Visible'), 'on')
    progress_target = handles.stereo_disp_report;
else
    progress_target = handles.overall;
end
set(progress_target, 'String', ['Measuring the disparity...' newline 'Remaining time: calculating...']);
try
    disparity = stereo.measure_disparity(imgs, calib, st, true, backgrounds, progress_target);
catch err
    gui.toolsavailable(1)
    stereo.update_panel(handles)
    gui.custom_msgbox('error', hgui, 'Disparity', ['The disparity measurement failed: ' err.message], 'modal');
    return
end
max_shift = ceil(max(abs([disparity.u_full(:); disparity.v_full(:)])) / 2);
disparity = rmfield(disparity, {'u_full', 'v_full', 'xq', 'yq'}); % large; made again when needed
disparity.report = stereo.disparity_report(calib, disparity);
gui.put('stereo_disparity', disparity);

% results were computed with the old correction
for name = {'resultslist', 'derived', 'ismean', 'manualdeletion', 'framemanualdeletion', 'streamlinesX', 'streamlinesY', ...
        'stereo_result', 'stereo_vel'}
    gui.put(name{1}, []);
end
other = 3 - gui.retr('stereo_active_camera');
state{other}.stereo_result = [];
gui.put('stereo_cam_state', state);
gui.put('displaywhat', 1);
stereo.update_maps
% automatic region of interest: inside the corrected overlap
roirect = gui.retr('roirect');
if isempty(roirect) || (isfield(calib, 'auto_roi') && isequal(roirect, calib.auto_roi))
    roirect = stereo.auto_roi(~calib.mask, max_shift + 2);
    calib.auto_roi = roirect;
    gui.put('stereo_calib', calib);
    gui.put('roirect', roirect);
    roi.updateROIinfo
end
gui.toolsavailable(1)
if strcmp(get(handles.multip30, 'Visible'), 'on')
    set(handles.stereo_disp_show, 'Value', 3); % show the fitted disparity map
end
stereo.update_panel(handles)
stereo.show_active_camera
masks = ~isempty(gui.retr('masks_in_frame')) || (isfield(state{3 - gui.retr('stereo_active_camera')}, 'masks_in_frame') ...
    && ~isempty(state{3 - gui.retr('stereo_active_camera')}.masks_in_frame));
if masks && ~batch
    gui.custom_msgbox('warn', hgui, 'Disparity', sprintf(['The images are now corrected by up to %d px. Masks that were drawn before ' ...
        'may have to be adapted.'], max_shift), 'modal');
end
end
