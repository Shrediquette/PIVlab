function measure_sheet_Callback
%MEASURE_SHEET_CALLBACK "Measure disparity" with two cameras combined into one image (larger field of view).
% Correlates both cameras in their overlap (stereo.gui_image_sets, settings of the disparity panel), finds the
% light sheet position (fov.measure_sheet) and maps both cameras onto the sheet (fov.apply_alignment). Results and
% the background are reset (they were computed with the old maps).
hgui = getappdata(0, 'hgui');
batch = isequal(gui.retr('batchModeActive'), 1);
handles = gui.gethand;
calib = gui.retr('fov_calib');
imgs = stereo.gui_image_sets(handles);
st = stereo.settings_from_gui(handles);
had_background = get(handles.bg_subtract, 'Value') > 1;
gui.toolsavailable(0, 'Measuring the disparity...'); drawnow
progress_target = handles.overall;
if strcmp(get(handles.multip30, 'Visible'), 'on')
    progress_target = handles.stereo_disp_report;
end
set(progress_target, 'String', ['Measuring the disparity in the overlap...' newline 'Remaining time: calculating...']);
try
    calib = fov.measure_sheet(imgs, calib, st, true, progress_target);
catch err
    gui.toolsavailable(1)
    stereo.update_panel(handles)
    gui.custom_msgbox('error', hgui, 'Disparity', ['The disparity measurement failed: ' err.message], 'modal');
    return
end
fov.apply_alignment(calib)
gui.toolsavailable(1)
gui.update_dependent_controls(handles) % toolsavailable(1) restores what was disabled before
stereo.update_panel(handles)
if ~batch
    text = strjoin(fov.sheet_report(calib), newline);
    text = [text newline newline 'Both cameras are now mapped onto the light sheet. Results were reset.'];
    if had_background
        text = [text ' Background subtraction is off: the background has to be computed again.'];
    end
    gui.custom_msgbox('success', hgui, 'Disparity in the overlap', text, 'modal');
end
end
