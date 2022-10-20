function [OutputError,OPTOcam_vid] = PIVlab_capture_OPTOcam_synced_capture(OPTOcam_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display,bitmode)
OPTOcam_climits=2^bitmode;
hgui=getappdata(0,'hgui');
image_handle_OPTOcam=getappdata(hgui,'image_handle_OPTOcam');
OutputError=0;

OPTOcam_frames_to_capture = nr_of_images*2;

%% capture data

while OPTOcam_vid.FramesAcquired < (OPTOcam_frames_to_capture) &&  getappdata(hgui,'cancel_capture') ~=1
	ima = image_handle_OPTOcam.CData;
	set(frame_nr_display,'String',['Image nr.: ' int2str(round(OPTOcam_vid.FramesAcquired/2))]);
	drawnow limitrate
	%% sharpness indicator
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1 % sharpness indicator
		textx=1240;
		texty=950;
		[~,~] = PIVlab_capture_sharpness_indicator (ima,textx,texty);
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
		set(image_handle_OPTOcam,'CData',ima_ed);
	end
	%% HISTOGRAM
	if getappdata(hgui,'hist_enabled')==1
		if isvalid(image_handle_OPTOcam)
			hist_fig=findobj('tag','hist_fig');
			if isempty(hist_fig)
				hist_fig=figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Live histogram','Toolbar','none','tag','hist_fig','CloseRequestFcn', @HistWindow_CloseRequestFcn);
			end
			if ~exist ('old_hist_y_limits','var')
				old_hist_y_limits =[0 35000];
			else
				if isvalid(hist_obj)
					old_hist_y_limits=get(hist_obj.Parent,'YLim');
				end
			end
			hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',hist_fig,'binlimits',[0 OPTOcam_climits]);
		end
		%lowpass hist y limits for better visibility
		if ~exist ('new_hist_y_limits','var')
			new_hist_y_limits =[0 35000];
		end
		new_hist_y_limits=get(hist_obj.Parent,'YLim');
		set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
	else
		hist_fig=findobj('tag','hist_fig');
		if ~isempty(hist_fig)
			close(hist_fig)
		end
	end
	drawnow limitrate;
	%% Autofocus
	%% Lens control
	%to be implemented...
end

stoppreview(OPTOcam_vid)
stop(OPTOcam_vid);
set(frame_nr_display,'String',['Image nr.: ' int2str(round(OPTOcam_vid.FramesAcquired/2))]);
drawnow;

function HistWindow_CloseRequestFcn(hObject,~)
hgui=getappdata(0,'hgui');
setappdata(hgui,'hist_enabled',0);
try
	delete(hObject);
catch
	delete(gcf);
end