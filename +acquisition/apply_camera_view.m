function apply_camera_view()
%APPLY_CAMERA_VIEW Shows the cameras of acquisition.camera_view in the image area (stereo live image / PIV
%capture): the axes limits are set to the shown camera images (zoom is reset), the status text is moved into
%the view, and the hidden camera is marked (appdata 'hidden' of its image object), so that acquisition.show_frame
%and acquisition.live_overlays skip it. Does nothing when no camera images are shown.
ax = gui.retr('pivlab_axis');
imgs = findobj(ax, 'Type', 'image');
view = acquisition.camera_view();
x_lo = inf;
x_hi = -inf;
y_hi = 0;
for i = 1:numel(imgs)
    k = getappdata(imgs(i), 'camera');
    if isempty(k)
        continue
    end
    shown = view == 0 || k == view;
    setappdata(imgs(i), 'hidden', ~shown);
    labels = findobj(ax, 'Tag', 'capture_camera_label'); % texts are not clipped: the label of a hidden camera would show at the edge
    for j = 1:numel(labels)
        if isequal(getappdata(labels(j), 'camera'), k)
            labels(j).Visible = matlab.lang.OnOffSwitchState(shown);
        end
    end
    if shown % full camera image (XData / YData cover only the part drawn by acquisition.show_frame)
        frame = getappdata(imgs(i), 'frame');
        x_offset = getappdata(imgs(i), 'x_offset');
        if isempty(x_offset)
            x_offset = 0;
        end
        if isempty(frame) && isappdata(imgs(i), 'image_size') % no frame yet, or rendered smaller (3D preview of the particle image generator)
            frame_size = getappdata(imgs(i), 'image_size');
        elseif isempty(frame)
            frame_size = size(imgs(i).CData);
        else
            frame_size = size(frame);
        end
        x_lo = min(x_lo, x_offset + 1);
        x_hi = max(x_hi, x_offset + frame_size(2));
        y_hi = max(y_hi, frame_size(1));
    end
end
if isinf(x_lo)
    return
end
set(ax, 'XLim', [x_lo - 0.5, x_hi + 0.5], 'YLim', [0.5, y_hi + 0.5]);
if ~isequal(getappdata(ax, 'applied_camera_view'), view) % not after a zoom reset: the overlays stay valid
    setappdata(ax, 'applied_camera_view', view);
    delete(findobj(ax, 'Tag', 'capture_grid')); % drawn again for the shown cameras (acquisition.live_overlays)
    delete(findobj(ax, '-regexp', 'Tag', '^charucolabel')); % live ChArUco detection: per camera (CAM 1+2) or full (CAM 1 / CAM 2), drawn again for the new view
end
acquisition.redraw_camera_images % the kept frames for the new limits (also when the cameras are stopped)
status = findobj(ax, 'Tag', 'capture_status_text');
for i = 1:numel(status)
    position = status(i).Position;
    status(i).Position = [x_lo - 1 + 100, position(2:end)];
end
end
