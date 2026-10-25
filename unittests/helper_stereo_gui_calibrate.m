function helper_stereo_gui_calibrate(c, import_images)
%HELPER_STEREO_GUI_CALIBRATE Stereo import, lens calibration + board image per camera, stereo calibration in the
%PIVlab window, without dialogs (unit tests; c = helper_stereo_synthetic_case).
%   helper_stereo_gui_calibrate(c)
%   helper_stereo_gui_calibrate(c, false)   the images are already imported
if nargin < 2
    import_images = true;
end
handles = gui.gethand;
if import_images
    gui.put('sequencer', 1);
    import.stereo_import_Callback([], [], {c.files{1}, c.files{2}});
end
for k = 1:2
    stereo.switch_camera(k);
    gui.put('cameraParams', c.lens{k});
    gui.put('cam_selected_rectification_image', c.boards{k});
end
stereo.switch_camera(1);
set(handles.calib_rows, 'String', int2str(c.board.PatternDims(1)));
set(handles.calib_columns, 'String', int2str(c.board.PatternDims(2)));
set(handles.calib_checkersize, 'String', num2str(c.board.CheckerSize));
set(handles.calib_markersize, 'String', num2str(c.board.MarkerSize));
set(handles.calib_origincolor, 'Value', 1);
stereo.calibrate_Callback;
end
