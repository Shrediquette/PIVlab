function limits_changed(src, ~)
%LIMITS_CHANGED LimitsChangedFcn of the PIVlab axes rulers while a large frame is shown at screen resolution.
%   Any change of the axes limits (zoom and pan tools, scroll wheel zoom and drag pan of the axes,
%   zoom reset, limits set by code) draws the frame again for the new view when needed
%   (plot.redraw_display_resolution). Skipped while PIVlab draws a frame or resets the zoom: these
%   set 'drawing_frame' (gui.sliderdisp, plot.redraw_display_resolution, gui.zoom_reset_zoom)
%   and draw the frame for the final limits themselves.
ax = ancestor(src, 'axes');
pivlab_axis = gui.retr('pivlab_axis');
if isempty(ax) || isempty(pivlab_axis) || ax ~= pivlab_axis
	return
end
if isequal(gui.retr('drawing_frame'), true)
	return
end
plot.redraw_display_resolution();
end
