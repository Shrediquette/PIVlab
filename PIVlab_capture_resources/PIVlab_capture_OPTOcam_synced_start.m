function [OutputError,OPTOcam_vid,frame_nr_display] = PIVlab_capture_OPTOcam_synced_start(nr_of_images,ROI_OPTOcam,frame_rate,bitmode)

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

OPTOcam_name = info.DeviceInfo.DeviceName;
disp(['Found camera: ' OPTOcam_name])
OPTOcam_supported_formats = info.DeviceInfo.SupportedFormats;
%OPTOcam_vid = videoinput(info.AdaptorName,1,OPTOcam_supported_formats{1});


% open in 8 bit
if bitmode ==8
	OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo.DeviceID,'Mono8');
	% open in 12 bit
elseif bitmode==12
	OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo.DeviceID,'Mono12');
end

OPTOcam_settings = get(OPTOcam_vid);
OPTOcam_settings.Source.DeviceLinkThroughputLimitMode = 'off';
OPTOcam_settings.PreviewFullBitDepth='On';
OPTOcam_vid.PreviewFullBitDepth='On';

%% prepare axes
PIVlab_axis = findobj(hgui,'Type','Axes');
OPTOcam_climits=2^bitmode;
image_handle_OPTOcam=imagesc(zeros(ROI_OPTOcam(4),ROI_OPTOcam(3)),'Parent',PIVlab_axis,[0 OPTOcam_climits]);
setappdata(hgui,'image_handle_OPTOcam',image_handle_OPTOcam);

frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar


%% set camera parameters for triggered acquisition
triggerconfig(OPTOcam_vid, 'hardware');
OPTOcam_settings.TriggerSource = 'Line2';
OPTOcam_settings.Source.ExposureMode = 'Timed';
OPTOcam_settings.Source.TriggerSource ='Line2';
OPTOcam_settings.Source.TriggerSelector='FrameStart';
OPTOcam_settings.Source.TriggerMode ='On';

%% set line3 to output exposureactive signal
OPTOcam_settings.Source.LineSelector='Line4';
OPTOcam_settings.Source.LineSource = 'ExposureActive';
OPTOcam_settings.Source.LineMode = 'Output';

if bitmode==8
	exposure_time= floor(1/frame_rate*1000*1000-44);
elseif bitmode==12
	exposure_time= floor(1/frame_rate*1000*1000-96);
end

OPTOcam_settings.Source.ExposureTime =exposure_time;

OPTOcam_settings.Source.LineInverter='False';

ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %unfortunaletly different definitions of ROI in pco and OPTOcam.
OPTOcam_vid.ROIPosition=ROI_OPTOcam;


OPTOcam_settings.Source.ReverseX = 'True';
OPTOcam_settings.Source.ReverseY = 'True';
OPTOcam_gain = getappdata(hgui,'OPTOcam_gain');
if isempty (OPTOcam_gain)
	OPTOcam_gain=0;
end
OPTOcam_settings.Source.Gain = OPTOcam_gain;

%% start acqusition (waiting for trigger)
OPTOcam_frames_to_capture = nr_of_images*2;
OPTOcam_vid.FramesPerTrigger = OPTOcam_frames_to_capture;
if ~isinf(nr_of_images) %only start capturing if save box is ticked.
	flushdata(OPTOcam_vid);
	start(OPTOcam_vid);
end
preview(OPTOcam_vid,image_handle_OPTOcam);
% open in 8 bit
if bitmode ==8
	clim([0 2^8]); %seems to be a workaround to force preview to show full data range...
	% open in 12 bit
elseif bitmode==12
	clim([0 2^12]); %seems to be a workaround to force preview to show full data range...
end
drawnow;