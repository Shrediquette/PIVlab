function w_limit_roi_events(src, evt)
%The green range of the W histogram (validate.w_limit_select_Callback).
%MovingROI: keeps the full height (only W min / W max matter) and writes W min / W max into the panel,
%ticks "W limits". ROIMoved: colours the histogram (green inside, red outside). DeletingROI (the range is
%deleted with its context menu, not when the window is closed): unticks "W limits".
handles = gui.gethand;
switch evt.EventName
    case 'MovingROI'
        y_range = ylim(src.Parent);
        position = src.Position;
        if position(2) ~= y_range(1) || position(4) ~= y_range(2) - y_range(1)
            src.Position = [position(1) y_range(1) position(3) y_range(2) - y_range(1)];
        end
        set(handles.w_limit_min, 'String', sprintf('%.4g', position(1)));
        set(handles.w_limit_max, 'String', sprintf('%.4g', position(1) + position(3)));
        set(handles.w_limit_enable, 'Value', 1);
    case 'ROIMoved'
        limit_figure = ancestor(src, 'figure');
        W = getappdata(limit_figure, 'w_values');
        histograms = getappdata(limit_figure, 'w_histograms');
        inside = W >= src.Position(1) & W <= src.Position(1) + src.Position(3);
        set(histograms(1), 'Data', W(inside));
        set(histograms(2), 'Data', W(~inside));
    case 'DeletingROI'
        if ~strcmp(get(ancestor(src, 'figure'), 'BeingDeleted'), 'on') % not when the window is closed
            set(handles.w_limit_enable, 'Value', 0);
        end
end
