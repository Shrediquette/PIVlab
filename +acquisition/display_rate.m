function rate = display_rate(himg, max_rate, budget)
%DISPLAY_RATE Camera images drawn per second, from the number of pixels that are actually drawn.
%   rate = acquisition.display_rate(himg, max_rate, budget)
%   himg      image objects of acquisition.live_images (cell)
%   max_rate  upper limit (images per second and camera)
%   budget    pixels drawn per second, all shown cameras together (CPU load: PIVlab must stay responsive,
%             e.g. for the Stop button, and in the PIV capture the cameras must not lose frames)
%   The pixels drawn depend on the screen size, zoom and the cameras shown (acquisition.drawn_part,
%   acquisition.camera_view), not on the camera resolution. The rate is stored as appdata 'max_display_rate' of
%   each image (read by the preview callbacks). Call it again when the zoom or the view changes (cheap).
pixels = 0;
for k = 1:numel(himg)
    if ~isvalid(himg{k}) || isequal(getappdata(himg{k}, 'hidden'), true)
        continue
    end
    frame = getappdata(himg{k}, 'frame');
    if isempty(frame)
        frame_size = size(himg{k}.CData); % no camera frame yet: the placeholder has the camera size
    else
        frame_size = size(frame);
    end
    x_offset = getappdata(himg{k}, 'x_offset');
    if isempty(x_offset)
        x_offset = 0;
    end
    [rows, cols] = acquisition.drawn_part(himg{k}, frame_size(1:2), x_offset, 1);
    pixels = pixels + numel(rows) * numel(cols);
end
rate = max_rate;
if pixels > 0
    rate = min(max_rate, budget / pixels);
end
for k = 1:numel(himg)
    if isvalid(himg{k})
        setappdata(himg{k}, 'max_display_rate', rate);
    end
end
end
