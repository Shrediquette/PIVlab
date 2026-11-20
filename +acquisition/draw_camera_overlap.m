function draw_camera_overlap(PIVlab_axis, x_offsets)
%DRAW_CAMERA_OVERLAP Stereo live image with both cameras shown: the view of the other camera in each camera image,
%from the ChArUco board that both cameras see (for aligning the cameras).
%   acquisition.draw_camera_overlap(PIVlab_axis, x_offsets)
%   x_offsets   [1x2] x offset of camera 1 and 2 in the PIVlab axis (side by side)
%   The markers of the current frame come from PIVlab_capture_charuco_detector (gui 'charuco_live_markers').
%   Outlines only (dashed). Without a board that both cameras see, nothing is shown. The status block of each
%   camera (PIVlab_capture_charuco_detector) gets the line "Overlap: xx %" (part of this camera's image that the
%   other camera sees too; "-" without a common board, so that the block keeps its height).
delete(findobj(PIVlab_axis, 'tag', 'charucolabel_overlap'));
markers = gui.retr('charuco_live_markers');
ov.ok = false;
if iscell(markers) && numel(markers) == 2
	ov = acquisition.camera_overlap(markers);
end
for k = 1:2
	if ov.ok
		add_status_line(PIVlab_axis, k, sprintf('Overlap: %d %%', round(ov.fraction(k)*100)));
	else
		add_status_line(PIVlab_axis, k, 'Overlap: -');
	end
end
if ~ov.ok
	return
end
for k = 1:2
	other = 3 - k;
	color = stereo.camera_colors(other); % the frame of camera 1 in camera 1's colour (blue), camera 2 orange
	region = ov.region{k};
	if region.NumRegions == 0
		continue
	end
	pieces = regions(region);
	for r = 1:numel(pieces)
		[x, y] = boundary(pieces(r));
		% boundary repeats the first vertex at the end; patch closes the outline itself, and the zero length edge
		% would draw a spike at that corner
		x(end) = [];
		y(end) = [];
		patch(PIVlab_axis, x + x_offsets(k), y, color, 'FaceColor', 'none', 'EdgeColor', color, 'LineWidth', 2, 'LineStyle', '--', 'LineJoin', 'round', 'tag', 'charucolabel_overlap', 'HitTest', 'off');
	end
end

function add_status_line(PIVlab_axis, camera, line)
%below the first line ("Markers: x %") of the camera's status block, which the detection has just written
status = findobj(PIVlab_axis, 'tag', sprintf('charucolabel_status_cam%d', camera));
if isempty(status)
	return
end
lines = cellstr(status(1).String);
set(status(1), 'String', {lines{1}, line});
