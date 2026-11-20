function after_view_change(src, evt)
%AFTER_VIEW_CHANGE Called after zoom and pan (ActionPostCallback) and after the zoom reset.
%   Draws the images that are shown at screen resolution again for the new axes limits: live camera
%   images (acquisition.redraw_camera_images) and large frames (plot.redraw_display_resolution).
if nargin < 1
	src = [];
	evt = [];
end
acquisition.redraw_camera_images(src, evt);
plot.redraw_display_resolution(src, evt);
end
