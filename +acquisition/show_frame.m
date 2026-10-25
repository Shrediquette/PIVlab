function show_frame(himg, frame, ds)
%SHOW_FRAME Put one camera frame into its image object (acquisition.live_images).
%   acquisition.show_frame(himg, frame, ds): every ds-th pixel is displayed (ds = 1: full resolution). The
%   axes stay in camera pixels (XData, YData), camera 2 is shifted by its x offset. The full frame is kept
%   for the overlays (sharpness, ChArUco detection): getappdata(himg, 'frame').
if ~isvalid(himg)
    return
end
frame = frame(:, :, 1);
setappdata(himg, 'frame', frame);
x_offset = getappdata(himg, 'x_offset');
if isempty(x_offset)
    x_offset = 0;
end
x_data = [1 size(frame, 2)] + x_offset;
y_data = [1 size(frame, 1)];
if isequal(himg.XData, x_data) && isequal(himg.YData, y_data)
    set(himg, 'CData', frame(1:ds:end, 1:ds:end));
else % first frame: setting XData / YData every time makes MATLAB lay out the axes again (CPU time)
    set(himg, 'CData', frame(1:ds:end, 1:ds:end), 'XData', x_data, 'YData', y_data);
end
end
