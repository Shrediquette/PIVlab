function cam_show_cam_position_Callback(~, ~, ~)
% "Show camera position" of the calibration images: board and camera positions in 3D (camcal.show_extrinsics)
cameraParams = gui.retr('cameraParams');
cam_selected_target_images = gui.retr('cam_selected_target_images');
if ~isempty(cameraParams) && ~isempty (cam_selected_target_images)
    fig = figure('Name', 'Camera positions', 'DockControls', 'off', 'WindowStyle', 'normal', 'Scrollable', 'off', ...
        'ToolBar', 'none', 'MenuBar', 'figure', 'Resize', 'on', 'NumberTitle', 'off');
    camcal.show_extrinsics(cameraParams, fig, stereo.board_from_gui(gui.gethand))
end
end
