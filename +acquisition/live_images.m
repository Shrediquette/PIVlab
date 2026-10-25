function [himg, frame_nr_display] = live_images(n, image_size, climit)
%LIVE_IMAGES Image objects for the camera images in the PIVlab image area (live image, PIV preview, capture).
%   [himg, frame_nr_display] = acquisition.live_images(n, image_size, climit)
%   n                 number of cameras: 1, or 2 for stereo (side by side, camera 2 right of camera 1)
%   image_size        [width height] of one camera image in pixels (camera ROI)
%   climit            upper colour limit (2^bits)
%   himg              cell with one image object per camera; acquisition.show_frame puts a frame into it.
%                     The axes are in camera pixels; camera k starts at x = getappdata(himg{k}, 'x_offset') + 1.
%   frame_nr_display  status text in the top left corner ("Initializing...", "Image nr.: ...")
PIVlab_axis = gui.retr('pivlab_axis');
w = image_size(1);
h = image_size(2);
gap = 0;
if n > 1
    gap = round(0.03 * w);
end
himg = cell(1, n);
for k = 1:n
    x_offset = (k - 1) * (w + gap);
    if k == 1
        himg{k} = imagesc(zeros(h, w), 'Parent', PIVlab_axis, [0 climit]); % replaces the content of the axes
        set(himg{k}, 'XData', [1 w], 'YData', [1 h]); % fixed (not 'auto'): a downsampled CData keeps the camera pixel coordinates
    else
        himg{k} = image('CData', zeros(h, w), 'XData', [1 w] + x_offset, 'YData', [1 h], 'CDataMapping', 'scaled', 'Parent', PIVlab_axis);
    end
    setappdata(himg{k}, 'x_offset', x_offset);
    setappdata(himg{k}, 'camera', k);
end
if n > 1
    for k = 1:n
        [cam_color, text_color] = stereo.camera_colors(k);
        text(PIVlab_axis, getappdata(himg{k}, 'x_offset') + 1, h, [' CAMERA ' int2str(k) ' '], 'VerticalAlignment', 'bottom', ...
            'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', cam_color, ...
            'Color', text_color, 'Margin', 2, 'Tag', 'capture_camera_label', 'HitTest', 'off', 'PickableParts', 'none');
    end
end
frame_nr_display = text(PIVlab_axis, 100, 100, 'Initializing...', 'Color', [1 1 0]);
colormap(ancestor(PIVlab_axis, 'figure'), 'default') % reset colormap steps
new_map = colormap(ancestor(PIVlab_axis, 'figure'), 'gray');
new_map(1:3, :) = [0 0.2 0; 0 0.2 0; 0 0.2 0];
new_map(end-2:end, :) = [1 0.7 0.7; 1 0.7 0.7; 1 0.7 0.7];
colormap(ancestor(PIVlab_axis, 'figure'), new_map);
axis(PIVlab_axis, 'image');
set(PIVlab_axis, 'ytick', [])
set(PIVlab_axis, 'xtick', [])
caxis(PIVlab_axis, [0 climit]); %#ok<CAXIS> as the other capture code (clim needs R2022a)
colorbar(PIVlab_axis)
end
