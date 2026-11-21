function draw_camera_overlap(PIVlab_axis, x_offsets)
%DRAW_CAMERA_OVERLAP Stereo live image with both cameras shown: the view of the other camera in each camera image,
%from the ChArUco board that both cameras see (for aligning the cameras).
%   acquisition.draw_camera_overlap(PIVlab_axis, x_offsets)
%   x_offsets   [1x2] x offset of camera 1 and 2 in the PIVlab axis (side by side)
%   The markers of the current frame come from PIVlab_capture_charuco_detector (gui 'charuco_live_markers').
%   Outlines only (dashed). Without a board that both cameras see, nothing is shown. The status block of each
%   camera (PIVlab_capture_charuco_detector) gets the line "Overlap: xx %" (part of this camera's image that the
%   other camera sees too; "-" without a common board, so that the block keeps its height).
markers = gui.retr('charuco_live_markers');
ov.ok = false;
if iscell(markers) && numel(markers) == 2
	ov = acquisition.camera_overlap(markers);
end
for k = 1:2 % the frame of camera 1 in camera 1's colour (blue), camera 2 orange
	add_status_line(PIVlab_axis, k, acquisition.calib_overlay('overlap', PIVlab_axis, k, x_offsets(k), ov));
end

function add_status_line(PIVlab_axis, camera, line)
%below the first line ("Markers: x %") of the camera's status block, which the detection has just written
status = findobj(PIVlab_axis, 'tag', sprintf('charucolabel_status_cam%d', camera));
if isempty(status)
	return
end
lines = cellstr(status(1).String);
set(status(1), 'String', {lines{1}, line});
