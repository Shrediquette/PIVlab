function show_3d_Callback(~, ~, ~)
%SHOW_3D_CALLBACK "Show 3D setup" (Stereo-PIV panel): both cameras, the board and the overlap in 3D, with the
% report of the stereo calibration (stereo.geometry_report) in the figure.
calib = gui.retr('stereo_calib');
if isempty(calib)
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Stereo-PIV', 'Compute the stereo calibration first.', 'modal');
    return
end
fig = figure('Name', 'Stereo-PIV setup in 3D', 'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'figure', 'ToolBar', 'none');
ax = axes(fig);
stereo.plot_setup(ax, calib, gui.retr('stereo_disparity'));
cameratoolbar(fig, 'SetMode', 'orbit');
cameratoolbar(fig, 'SetCoordSys', 'y');
if isfield(calib, 'report') && ~isempty(calib.report)
    report = calib.report;
else
    report = stereo.geometry_report(calib);
end
% top left (the legend is top right); colours of the axes, so that it is readable in light and dark mode
annotation(fig, 'textbox', [0.01 0.78 0.45 0.2], 'String', report, 'FitBoxToText', 'on', 'BackgroundColor', get(ax, 'Color'), ...
    'Color', get(ax, 'XColor'), 'EdgeColor', get(ax, 'GridColor'), 'FontSize', 9, 'Interpreter', 'none', 'Tag', 'stereo_calib_report');
end
