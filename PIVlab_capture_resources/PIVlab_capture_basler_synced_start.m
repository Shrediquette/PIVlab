function [OutputError,basler_vid,frame_nr_display] = PIVlab_capture_basler_synced_start(nr_of_images,ROI_basler)

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

basler_name = info.DeviceInfo.DeviceName;
disp(['Found camera: ' basler_name])
basler_supported_formats = info.DeviceInfo.SupportedFormats;
%basler_vid = videoinput(info.AdaptorName,1,basler_supported_formats{1});
basler_vid = videoinput(info.AdaptorName);

basler_settings = get(basler_vid);
basler_settings.Source.DeviceLinkThroughputLimitMode = 'off';


%% prepare axes
PIVlab_axis = findobj(hgui,'Type','Axes');
image_handle_basler=imagesc(zeros(ROI_basler(4),ROI_basler(3)),'Parent',PIVlab_axis,[0 2^8]);
setappdata(hgui,'image_handle_basler',image_handle_basler);

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
triggerconfig(basler_vid, 'hardware');
basler_settings.TriggerSource = 'Line3';
basler_settings.Source.ExposureMode = 'TriggerWidth';
basler_settings.Source.TriggerSource ='Line3';
basler_settings.Source.TriggerSelector='FrameStart';
basler_settings.Source.TriggerMode ='On';
basler_settings.Source.ExposureOverlapTimeMax = basler_settings.Source.SensorReadoutTime;

ROI_basler=[ROI_basler(1)-1,ROI_basler(2)-1,ROI_basler(3),ROI_basler(4)]; %unfortunaletly different definitions of ROI in pco and basler.
basler_vid.ROIPosition=ROI_basler;

%% start acqusition (waiting for trigger)
basler_frames_to_capture = nr_of_images*2;
basler_vid.FramesPerTrigger = basler_frames_to_capture;
if ~isinf(nr_of_images) %only start capturing if save box is ticked.
	flushdata(basler_vid);
	start(basler_vid);
end
preview(basler_vid,image_handle_basler);
drawnow;