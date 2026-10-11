function show_rectified_board
%SHOW_RECTIFIED_BOARD "Show rectified board" in stereo-PIV mode after the stereo calibration.
%   stereo.show_rectified_board
% Shows the board image of the camera that is shown on the common grid of both cameras (rectified with
% the stereo calibration, without the disparity correction: the board defines the grid). Board corners
% must lie at the same pixel in both cameras.
calib = gui.retr('stereo_calib');
active = gui.retr('stereo_active_camera');
board_image = gui.retr('cam_selected_rectification_image');
if isempty(board_image)
    gui.custom_msgbox('error', getappdata(0, 'hgui'), 'Error', 'No board image loaded for this camera ("Load target image").', 'modal');
    return
end
plain = gui.retr('stereo_maps_plain'); % rectification without disparity correction, made once
if ~iscell(plain) || numel(plain) ~= 2 || isempty(plain{active})
    plain = {stereo.camera_map(calib, 1, []), stereo.camera_map(calib, 2, [])};
    gui.put('stereo_maps_plain', plain);
end
target_axis = gui.retr('pivlab_axis');
imshow(imadjust(stereo.rectify_map(imread(board_image), plain{active})), 'Parent', target_axis);
stereo.draw_camera_label(target_axis);
end
