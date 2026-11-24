function show_3d_Callback(~, ~, ~)
%SHOW_3D_CALLBACK "Show 3D setup" (Stereo-PIV panel): both cameras, the board and the overlap in 3D, with the
% report of the stereo calibration (stereo.geometry_report) in the figure.
calib = gui.retr('stereo_calib');
disparity = gui.retr('stereo_disparity');
if fov.gui_active % two cameras combined into one image (larger field of view)
    calib = gui.retr('fov_calib');
    disparity = [];
end
if isempty(calib) || ~isequal(gui.retr('stereomode'), 1) && ~fov.gui_active
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Stereo-PIV / multicam', 'Compute the 3D alignment first ("Compute stereo / 3D alignment").', 'modal');
    return
end
[~, ax] = scene3d.window(@(ax) stereo.plot_setup(ax, calib, disparity), Name='Camera setup in 3D');
if isfield(calib, 'report') && ~isempty(calib.report)
    report = calib.report;
else
    report = stereo.geometry_report(calib);
end
scene3d.info(ax, report, 'stereo_calib_report'); % top left, below the header line (the legend is top right)
end
