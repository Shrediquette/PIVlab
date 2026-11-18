function w_limit_select_Callback(caller, ~, ~)
%"Select" / "Auto" of the W limits (stereo based validation panel): a histogram of W (linear count axis)
%with a green range from W min to W max of the panel.
%Dragging the range writes W min / W max into the panel and ticks "W limits" (validate.w_limit_roi_events).
%"Auto" first sets the range to the main peak of the histogram (validate.w_limit_auto_range).
%W of the 3D result of the raw camera data, in the units of the velocity limits, as tested by
%stereo.limit_discard. Outside stereo-PIV the buttons do nothing.
handles = gui.gethand;
if ~isequal(gui.retr('stereomode'), 1) || isempty(gui.retr('stereo_calib'))
    return
end
gui.toolsavailable(0)
W = w_values(handles);
gui.toolsavailable(1)
if isempty(W)
    gui.custom_msgbox('msg', getappdata(0,'hgui'), 'W limits', ...
        ['The W histogram uses the 3D result of the camera data. ' ...
        'There is none for this frame (no analysis yet, or a mean frame).'], 'modal', {'OK'}, 'OK');
    return
end
edges = validate.w_limit_bin_edges(W);
if strcmp(get(caller, 'Tag'), 'w_limit_auto')
    range = validate.w_limit_auto_range(W, edges);
    set(handles.w_limit_min, 'String', sprintf('%.4g', range(1)));
    set(handles.w_limit_max, 'String', sprintf('%.4g', range(2)));
    set(handles.w_limit_enable, 'Value', 1);
end
range = sort([str2double(get(handles.w_limit_min, 'String')), str2double(get(handles.w_limit_max, 'String'))]);
if any(~isfinite(range))
    range = validate.w_limit_auto_range(W, edges); % only shown; written to the panel when the range is moved
end

delete(findobj('Tag', 'w_limit_figure'));
limit_figure = figure('Tag','w_limit_figure','MenuBar','none','DockControls','off','WindowStyle','modal','ToolBar','figure', ...
    'Name','Drag the green range to the allowed W. Close the window when done.','NumberTitle','off');
limit_ax = axes('Parent', limit_figure);
inside = W >= range(1) & W <= range(2);
h_in = histogram(limit_ax, W(inside), edges, 'FaceColor', [0 0.8 0], 'EdgeColor', 'none', 'FaceAlpha', 1);
hold(limit_ax, 'on')
h_out = histogram(limit_ax, W(~inside), edges, 'FaceColor', [1 0 0], 'EdgeColor', 'none', 'FaceAlpha', 1);
hold(limit_ax, 'off')
counts = histcounts(W, edges);
ylim(limit_ax, [0 max(counts) * 1.05]);
xlim(limit_ax, x_limits(edges, range));
grid(limit_ax, 'on')
xlabel(limit_ax, ['W (3D result) ' unit_text], 'fontsize', 12)
ylabel(limit_ax, 'Number of vectors', 'fontsize', 12)
setappdata(limit_figure, 'w_values', W);
setappdata(limit_figure, 'w_histograms', [h_in h_out]);

y_range = ylim(limit_ax);
roi = drawrectangle(limit_ax, 'Position', [range(1) y_range(1) range(2) - range(1) y_range(2) - y_range(1)], ...
    'Color', 'g', 'StripeColor', 'k', 'FaceAlpha', 0.1, 'Tag', 'w_limit_ROI', ...
    'Label', 'Close window when done', 'LabelVisible', 'hover');
addlistener(roi, 'MovingROI', @validate.w_limit_roi_events);
addlistener(roi, 'ROIMoved', @validate.w_limit_roi_events);
addlistener(roi, 'DeletingROI', @validate.w_limit_roi_events);
end

function W = w_values(handles)
%W of the raw 3D result of all frames or of the current frame, finite values, units of the velocity limits
W = [];
frame = floor(get(handles.fileselector, 'Value'));
if get(handles.w_hist_all_frames, 'Value') == 1
    resultslist = stereo.reconstruct_results(true);
else
    resultslist = stereo.reconstruct_results(true, frame);
end
if size(resultslist, 1) < 16
    return
end
factor = calibrate.w_factor(gui.retr('calu'), gui.retr('calv'));
for i = 1:size(resultslist, 2)
    if ~isempty(resultslist{16, i})
        w = double(resultslist{16, i}(:)) * factor;
        W = [W; w(isfinite(w))]; %#ok<AGROW>
    end
end
end

function limits = x_limits(edges, range)
%the whole histogram and the range, with a small margin
lo = min(edges(1), range(1));
hi = max(edges(end), range(2));
margin = (hi - lo) * 0.03;
limits = [lo - margin, hi + margin];
end

function s = unit_text
if (gui.retr('calu') == 1 || gui.retr('calu') == -1) && gui.retr('calxy') == 1
    s = '[px/frame]';
else
    displacement_only = gui.retr('displacement_only');
    if ~isempty(displacement_only) && displacement_only == 1
        s = '[m/frame]';
    else
        s = '[m/s]';
    end
end
end
