function redraw_camera_images(~, ~)
%REDRAW_CAMERA_IMAGES Draws the kept camera frames again for the current axes limits (acquisition.show_frame
%draws only the visible part at screen resolution). Called after zoom, pan and zoom reset, so that a zoomed
%camera image is sharp also when the camera is stopped.
ax = gui.retr('pivlab_axis');
imgs = findobj(ax, 'Type', 'image');
for i = 1:numel(imgs)
    if isappdata(imgs(i), 'camera')
        frame = getappdata(imgs(i), 'frame');
        if ~isempty(frame)
            acquisition.show_frame(imgs(i), frame, 1);
        end
    end
end
end
