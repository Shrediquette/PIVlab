function show_3d_Callback(~, ~, ~)
%SHOW_3D_CALLBACK "Show 3D setup" (Stereo-PIV panel): both cameras, the board and the overlap in 3D.
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
end
