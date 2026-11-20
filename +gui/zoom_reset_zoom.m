function zoom_reset_zoom(~,~)
% large frames at screen resolution are drawn once at the end, not for every limit change on the
% way (plot.limits_changed skips limit changes while 'drawing_frame' is set)
was_drawing = gui.retr('drawing_frame');
gui.put('drawing_frame', true);
try
	redraw = reset_limits();
catch ME
	gui.put('drawing_frame', was_drawing);
	rethrow(ME)
end
gui.put('drawing_frame', was_drawing);
if redraw
	plot.redraw_display_resolution % large frames: the whole image at screen resolution
end
end

function redraw = reset_limits()
redraw = false;
current_ax=gui.retr('pivlab_axis');
handles=gui.gethand;
setappdata(getappdata(0,'hgui'),'xzoomlimit',[]);
setappdata(getappdata(0,'hgui'),'yzoomlimit',[]);
%zoom reset
zoom out
set(handles.zoomon,'Value',0);
set(handles.panon,'Value',0);
zoom(current_ax,'off')
pan(current_ax,'off')
all_images=findobj(current_ax,'Type','Image');
for i=1:numel(all_images)
	if isappdata(all_images(i),'camera') %live image / PIV capture: the cameras shown (stereo: both or the one chosen with the CAM button)
		acquisition.apply_camera_view
		return
	end
end
expected_image_size=gui.retr('expected_image_size');
pcopanda_dbl_image=gui.retr('pcopanda_dbl_image');
if isempty(pcopanda_dbl_image)
    pcopanda_dbl_image=0;
end

if isempty(expected_image_size) %happens when no images are yet loaded
    if isappdata(current_ax, 'display_resolution_state') && ~isempty(findobj(current_ax, 'Type', 'image', 'Tag', 'pivlab_display_frame'))
        % large frame drawn at screen resolution: CData is smaller than the image
        state = getappdata(current_ax, 'display_resolution_state');
        expected_image_size = state.full_size;
    else
        current_img=findall(current_ax,'Type','Image');
        if ~isempty(current_img)
            current_img=current_img(1);
            expected_image_size=[size(current_img.CData,1) size(current_img.CData,2)];
        else
            return
        end
    end
end

set(gui.retr('pivlab_axis'),'xlim',[0.5 expected_image_size(2)+0.5])
set(gui.retr('pivlab_axis'),'ylim',[0.5 expected_image_size(1)+0.5])
redraw = true;
end
