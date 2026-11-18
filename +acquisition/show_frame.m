function show_frame(himg, frame, ds)
%SHOW_FRAME Put one camera frame into its image object (acquisition.live_images).
%   acquisition.show_frame(himg, frame, ds): at most every ds-th pixel is displayed (ds = 1: as fine as needed).
%   Only the pixels the screen can show are drawn (acquisition.drawn_part): the part of the frame inside the
%   axes limits (zoom), at about one image pixel per screen pixel (drawing full camera frames costs a lot of CPU
%   time). The axes stay in camera pixels (XData, YData), camera 2 is shifted by its x offset. The full frame is
%   kept for the overlays (sharpness, ChArUco detection), the snapshot and the ROI selection:
%   getappdata(himg, 'frame'). After zoom / pan, acquisition.redraw_camera_images draws the kept frames again.
%   appdata 'frames_drawn' of himg counts the drawn frames.
if ~isvalid(himg)
    return
end
frame = frame(:, :, 1);
setappdata(himg, 'frame', frame);
if isequal(getappdata(himg, 'hidden'), true)
    return % stereo: this camera is not shown (acquisition.apply_camera_view); the frame is kept for the snapshot
end
x_offset = getappdata(himg, 'x_offset');
if isempty(x_offset)
    x_offset = 0;
end
[rows, cols, step] = acquisition.drawn_part(himg, size(frame), x_offset, ds);
centre = (step - 1) / 2; % a displayed pixel stands for step x step camera pixels
x_data = [cols(1) cols(end)] + centre + x_offset;
y_data = [rows(1) rows(end)] + centre;
if isequal(himg.XData, x_data) && isequal(himg.YData, y_data)
    set(himg, 'CData', frame(rows, cols));
else % new size / zoom: setting XData / YData every time makes MATLAB lay out the axes again (CPU time)
    set(himg, 'CData', frame(rows, cols), 'XData', x_data, 'YData', y_data);
end
drawn = getappdata(himg, 'frames_drawn');
if isempty(drawn)
    drawn = 0;
end
setappdata(himg, 'frames_drawn', drawn + 1);
end
