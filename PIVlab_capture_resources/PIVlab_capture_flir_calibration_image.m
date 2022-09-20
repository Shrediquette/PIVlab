function [OutputError,ima,frame_nr_display] = PIVlab_capture_flir_calibration_image(exposure_time)
OutputError=0;
%% Prepare camera
delete(imaqfind); %clears all previous videoinputs
try
	hwinf = imaqhwinfo;
	%imaqreset
catch
	disp('Error: Image Acquisition Toolbox not available!')
end

info = imaqhwinfo(hwinf.InstalledAdaptors{1});

if strcmp(info.AdaptorName,'gentl')
	disp('gentl adaptor found.')
else
	disp('ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "gentl" to install it.')
end

flir_name = info.DeviceInfo.DeviceName;
disp(['Found camera: ' flir_name])
flir_supported_formats = info.DeviceInfo.SupportedFormats;
%flir_vid = videoinput(info.AdaptorName,1,flir_supported_formats{1});
flir_vid = videoinput(info.AdaptorName);

flir_settings = get(flir_vid);
flir_settings.Source.DeviceLinkThroughputLimit = flir_settings.Source.DeviceLinkSpeed;


triggerconfig(flir_vid, 'manual');
flir_settings.TriggerMode ='manual';
flir_settings.Source.TriggerMode ='Off';
flir_settings.Source.ExposureMode ='Timed';
flir_settings.Source.ExposureTime =exposure_time;

%% prapare axis
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
PIVlab_axis = findobj(hgui,'Type','Axes');

image_handle_flir=imagesc(zeros(flir_settings.VideoResolution(2),flir_settings.VideoResolution(1)),'Parent',PIVlab_axis,[0 2^8]);

setappdata(hgui,'image_handle_flir',image_handle_flir);

frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar


%% get images
flir_vid.FramesPerTrigger = 1;
set(frame_nr_display,'String','');
preview(flir_vid,image_handle_flir)
while getappdata(hgui,'cancel_capture') ~=1
	ima = image_handle_flir.CData;
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
		set(image_handle_flir,'CData',ima_ed);
	end
	%% HISTOGRAM
	if getappdata(hgui,'hist_enabled')==1
		if isvalid(image_handle_flir)
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
			hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',hist_fig,'binlimits',[0 255]);
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
stoppreview(flir_vid)



function HistWindow_CloseRequestFcn(hObject,~)
hgui=getappdata(0,'hgui');
setappdata(hgui,'hist_enabled',0);
try
	delete(hObject);
catch
	delete(gcf);
end
