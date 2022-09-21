function [OutputError,flir_vid,frame_nr_display] = PIVlab_capture_flir_synced_start(nr_of_images,frame_rate)

hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
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

%% prepare axes
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


%% set camera parameters for free run or triggered acquisition
flir_settings.Source.TriggerSource='Line2';
flir_settings.Source.TriggerActivation='RisingEdge';
flir_settings.Source.TriggerMode='On';
flir_settings.Source.TriggerSelector='FrameStart';
flir_settings.Source.ExposureMode = 'Timed'; %triggerwidth doesn't work with flir
triggerconfig(flir_vid, 'hardware');
%trigger width setting does not work on the FLIR, therefore using exposure time.
%min blind time between frames is 400 µs
flir_settings.Source.ExposureTime = floor(1/frame_rate*1000*1000-405);

%% Set Line3 to output ExposureActive Signal for debugging:
flir_settings.Source.LineSelector='Line3';
flir_settings.Source.LineSource = 'ExposureActive';
flir_settings.Source.LineMode = 'Output';
flir_settings.Source.LineInverter='False';

%% start acqusition (waiting for trigger)
flir_frames_to_capture = nr_of_images*2;
flir_vid.FramesPerTrigger = flir_frames_to_capture;
if ~isinf(nr_of_images) %only start capturing if save box is ticked.
	flushdata(flir_vid);
	start(flir_vid);
end
preview(flir_vid,image_handle_flir);
drawnow;