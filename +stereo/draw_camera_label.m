function draw_camera_label(target_axis)
%DRAW_CAMERA_LABEL Coloured "CAMERA 1" / "CAMERA 2" label in the top left corner of the image (stereo-PIV).
%   stereo.draw_camera_label(target_axis): only in stereo mode; the old label is removed first.
delete(findobj(target_axis, 'Tag', 'stereo_camera_label'));
if ~isequal(gui.retr('stereomode'), 1)
    return
end
active = gui.retr('stereo_active_camera');
if isempty(active)
    active = 1;
end
[cam_color, text_color] = stereo.camera_colors(active);
text(target_axis, 0.01, 0.99, [' CAMERA ' int2str(active) ' '], 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', cam_color, ...
    'Color', text_color, 'Margin', 2, 'Tag', 'stereo_camera_label', 'HitTest', 'off', 'PickableParts', 'none');
end
