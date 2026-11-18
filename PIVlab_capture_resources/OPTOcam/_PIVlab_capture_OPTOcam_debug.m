
% Prepare camera
delete(imaqfind); %clears all previous videoinputs
hwinf = imaqhwinfo;
info = imaqhwinfo(hwinf.InstalledAdaptors{1});
OPTOcam_name = info.DeviceInfo.DeviceName;
OPTOcam_supported_formats = info.DeviceInfo.SupportedFormats;

% open in 8 bit
OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo.DeviceID,'Mono8');
% open in 12 bit
%OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo.DeviceID,'Mono12');

OPTOcam_settings = get(OPTOcam_vid);
OPTOcam_settings.Source.DeviceLinkThroughputLimitMode = 'off';
OPTOcam_settings.PreviewFullBitDepth='On';
OPTOcam_vid.PreviewFullBitDepth='On';
for i=1:3
	OPTOcam_settings.Source.DeviceIndicatorMode = 'Active'; %LED off
	pause(0.05)
	OPTOcam_settings.Source.DeviceIndicatorMode = 'Inactive'; %LED off
	pause(0.05)
end
%% set camera parameters for triggered acquisition

triggerconfig(OPTOcam_vid, 'hardware');
OPTOcam_settings.TriggerSource = 'Line2';
OPTOcam_settings.Source.ExposureMode = 'Timed';
OPTOcam_settings.Source.TriggerSource ='Line2';
OPTOcam_settings.Source.TriggerSelector='FrameStart';
OPTOcam_settings.Source.TriggerMode ='On';


%% set to free run
exposure_time=30000;
triggerconfig(OPTOcam_vid, 'manual');
OPTOcam_settings.TriggerMode ='manual';
OPTOcam_settings.Source.TriggerMode ='Off';
OPTOcam_settings.Source.ExposureMode ='Timed';
OPTOcam_settings.Source.ExposureTime =exposure_time;


%% set line3 to output exposureactive signal
OPTOcam_settings.Source.LineSelector='Line4';
OPTOcam_settings.Source.LineSource = 'ExposureActive';
OPTOcam_settings.Source.LineMode = 'Output';
OPTOcam_settings.Source.LineInverter='False';


%% set ROI
ROI_OPTOcam=[1,1,1936,1216];
%ROI_OPTOcam=[1,1,1600,480];
ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %unfortunaletly different definitions of ROI in pco and basler.
OPTOcam_vid.ROIPosition=ROI_OPTOcam;




image_handle_OPTOcam=imagesc(zeros(OPTOcam_settings.VideoResolution(2),OPTOcam_settings.VideoResolution(1)),[0 2^12]);
axis image
axis off
colorbar
preview(OPTOcam_vid,image_handle_OPTOcam)
clim([0 2^12]);


bla=getsnapshot(OPTOcam_vid);

stoppreview(OPTOcam_vid)

