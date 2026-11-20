function redraw_display_resolution(~, ~)
%REDRAW_DISPLAY_RESOLUTION Draw a large frame again for new axes limits (after zoom, pan, zoom reset).
%   plot.redraw_display_resolution
%   Large images are drawn at screen resolution, only the visible part when zoomed in
%   (plot.draw_pixel_background_overlay). After the axes limits changed, the particle image, the map
%   and the mask preview are computed for the new view and put into the images that are drawn
%   (nothing else in the axes changes: vectors, ROI, masks, extraction objects stay). Does nothing
%   when the drawn region still covers the view at the needed resolution, or when the frame was
%   drawn at full resolution.
ax = gui.retr('pivlab_axis');
if isempty(ax) || ~isgraphics(ax, 'axes') || ~isappdata(ax, 'display_resolution_state')
	return
end
state = getappdata(ax, 'display_resolution_state');
if isempty(findobj(ax, 'Type', 'image', 'Tag', 'pivlab_display_frame'))
	return % another display was drawn in the meantime (e.g. preview of the pre-processing)
end
handles = gui.gethand;
toggler = gui.retr('toggler');
selected = 2*floor(get(handles.fileselector, 'value'))-(1-toggler);
if selected ~= state.selected
	return % the frame changed: gui.sliderdisp draws it
end
% still sharp enough and covering the view?
limits = [get(ax,'XLim') get(ax,'YLim')];
vis = [max(limits(1), 0.5), min(limits(2), state.full_size(2) + 0.5), max(limits(3), 0.5), min(limits(4), state.full_size(1) + 0.5)];
covered = vis(1) >= state.region(1) && vis(2) <= state.region(2) && vis(3) >= state.region(3) && vis(4) <= state.region(4);
new_grid = plot.display_grid(ax, state.full_size, limits);
if isempty(new_grid)
	return
end
if covered && floor(new_grid.step) == floor(state.step)
	return
end
% limit changes while drawing do not start another redraw (plot.limits_changed)
was_drawing = gui.retr('drawing_frame');
gui.put('drawing_frame', true);
try
	plot.draw_pixel_background_overlay(ax, state.displaywhat, state.selected, handles, state.currentframe, state.image_only, true);
catch ME
	gui.put('drawing_frame', was_drawing);
	rethrow(ME)
end
gui.put('drawing_frame', was_drawing);
end
