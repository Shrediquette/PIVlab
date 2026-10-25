function [OutputError,flir_vid] = PIVlab_capture_flir_synced_capture(flir_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display)

hgui=getappdata(0,'hgui');
image_handle_flir=getappdata(hgui,'image_handle_flir');
OutputError=0;

flir_frames_to_capture = nr_of_images*2;

%% capture data

while flir_vid.FramesAcquired < (flir_frames_to_capture) &&  getappdata(hgui,'cancel_capture') ~=1
	ima = image_handle_flir.CData;
	set(frame_nr_display,'String',['Image nr.: ' int2str(round(flir_vid.FramesAcquired/2))]);
	drawnow limitrate
	%% sharpness indicator
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1 % sharpness indicator
		[~,~] = PIVlab_capture_sharpness_indicator (ima,1);
	else
		delete(findobj('tag','sharpness_display_text'));
	end
	crosshair_enabled = getappdata(hgui,'crosshair_enabled');
	if crosshair_enabled == 1 %cross-hair
		%% cross-hair
		locations=[0.15 0.5 0.85];
		half_thickness=1;
		brightness_incr=101;
		ima_ed=ima;
		old_max=max(ima(:));
		for loca=locations
			%vertical
			ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)=ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)+brightness_incr;
			%horizontal
			ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)=ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)+brightness_incr;
		end
		ima_ed(ima_ed>old_max)=old_max;
		set(image_handle_flir,'CData',ima_ed);
	end
	drawnow limitrate;
	%% Autofocus
	%% Lens control
	%to be implemented...
end

stoppreview(flir_vid)
stop(flir_vid);
set(frame_nr_display,'String',['Image nr.: ' int2str(round(flir_vid.FramesAcquired/2))]);
drawnow;
