function [OutputError,ima,frame_nr_display] = PIVlab_capture_basler_calibration_image(exposure_time)
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

triggerconfig(basler_vid, 'manual');
basler_settings.TriggerMode ='manual';
basler_settings.Source.TriggerMode ='Off';
basler_settings.Source.ExposureMode ='Timed';
basler_settings.Source.ExposureTime =exposure_time;

%% prapare axis
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
PIVlab_axis = findobj(hgui,'Type','Axes');

image_handle_basler=imagesc(zeros(basler_settings.VideoResolution(2),basler_settings.VideoResolution(1)),'Parent',PIVlab_axis,[0 2^8]);

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


%% get images

basler_vid.FramesPerTrigger = 1;
set(frame_nr_display,'String','');
preview(basler_vid,image_handle_basler)
while getappdata(hgui,'cancel_capture') ~=1
	drawnow limitrate;

	%% Autofocus
	%% Lens control
	%to be implemented...
end
stoppreview(basler_vid)
ima = image_handle_basler.CData;
















%{

%% Kamera öffnen

close all
clear all
clc

imaqreset
hwinf = imaqhwinfo;
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

%% Preview machen
%preview(vid, hImage); %hImage ist handle zu hImage=imagesc(bla)
triggerconfig(basler_vid, 'manual');
basler_settings.TriggerMode ='manual';
basler_settings.Source.TriggerMode ='Off';
basler_settings.Source.ExposureMode ='Timed';
basler_settings.Source.ExposureTime =20000;

%% PIV images capturen
triggerconfig(basler_vid, 'hardware');
basler_settings.TriggerSource = 'Line1';
basler_settings.Source.ExposureMode = 'TriggerWidth';
basler_settings.Source.TriggerSource ='Line1';
basler_settings.Source.TriggerSelector='FrameStart';
basler_settings.Source.TriggerMode ='On';
basler_settings.Source.ExposureOverlapTimeMax = basler_settings.Source.SensorReadoutTime;

basler_frames_to_capture = 50;
basler_vid.FramesPerTrigger = basler_frames_to_capture;

start(basler_vid);
figure;
while basler_vid.FramesAcquired < (basler_frames_to_capture-1)
	%frame = getsnapshot(basler_vid);
	pause(0.1)
	%das muss eleganter gehen....
	if islogging(basler_vid)
		frame = peekdata(basler_vid,1);
		imagesc(frame(:,:,:,1));
	end

end
disp('finished')
basler_data = getdata(basler_vid); %ruft alle Frames in RAM ab. Frame 1,2,3 sind müll
stop(basler_vid);
%preview(basler_vid);


%LoggingMode disk, disk+memory.
%Wenn im Memory ist, dann öfter mal abholen mit getdata, sonst speicher voll.

start(basler_vid);
isrunning(basler_vid)
islogging(basler_vid)
basler_vid.FramesAcquired %checken ob gleich der angeforderten frames -> dann fertig.
%}
