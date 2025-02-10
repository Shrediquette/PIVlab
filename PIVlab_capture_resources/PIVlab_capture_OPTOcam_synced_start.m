function [OutputError,OPTOcam_vid,frame_nr_display] = PIVlab_capture_OPTOcam_synced_start(nr_of_images,ROI_OPTOcam,frame_rate,bitmode)

hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
OutputError=0;

%% Prepare camera
imaq_error=0;
try
    delete(imaqfind); %clears all previous videoinputs
    warning off
    hwinf = imaqhwinfo;
    warning on
    %imaqreset
catch
    imaq_error=1;
end
if imaq_error==0
    if isempty(hwinf.InstalledAdaptors)
        imaq_error=2;
    end
end
if imaq_error==0
    info = imaqhwinfo(hwinf.InstalledAdaptors{1});
    found_correct_adaptor=0;
    for adaptorID=1:numel(hwinf.InstalledAdaptors)
        info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
        if strcmp(info.AdaptorName,'gentl')
            disp(['gentl adaptor found with ID: ' num2str(adaptorID)])
            found_correct_adaptor=1;
            break
        else
            imaq_error=2;
        end
    end
end
if imaq_error==0 && found_correct_adaptor ==1
    try
        %Getting camera device ID when multiple cameras are connected
        for CamID = 1: size(info.DeviceInfo,2)
            camName=info.DeviceInfo(CamID).DeviceName;
            if contains(camName,'160um','IgnoreCase',true) || contains(camName,'OPTOcam','IgnoreCase',true)
                break
            end
        end
        OPTOcam_name = info.DeviceInfo(CamID).DeviceName;
    catch
        imaq_error=3;
    end
end
if imaq_error==1
    errordlg('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','Error!','modal')
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
elseif imaq_error==2
    disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
    disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
    errordlg({'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'Error, support package missing','modal')
elseif imaq_error==3
    errordlg('Error: Camera not found! Is it connected?','Error!','modal')
end

disp(['Found camera: ' OPTOcam_name])

OPTOcam_supported_formats = info.DeviceInfo(CamID).SupportedFormats;
%OPTOcam_vid = videoinput(info.AdaptorName,1,OPTOcam_supported_formats{1});


% open in 8 bit
if bitmode ==8
    OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,'Mono8');
    % open in 12 bit
elseif bitmode==12
    OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,'Mono12');
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
    OPTOcam_vid.ErrorFcn = @CustomIMAQErrorFcn;
    start(OPTOcam_vid);
end

preview(OPTOcam_vid,image_handle_OPTOcam);
% open in 8 bit
if bitmode ==8
    caxis([0 2^8]); %seems to be a workaround to force preview to show full data range...
    % open in 12 bit
elseif bitmode==12
    caxis([0 2^12]); %seems to be a workaround to force preview to show full data range...
end
pause(0.1); %make sure OPTOcam is ready...
if ~isinf(nr_of_images)
    status=[];
    while isempty(status) %make sure OPTOcam is ready...
        status=OPTOcam_vid.Eventlog;
        pause(0.001)
    end
end
drawnow;

function CustomIMAQErrorFcn(obj, event, varargin)
stop(obj)
hgui=getappdata(0,'hgui');
setappdata(hgui,'cancel_capture',1)

% Define error identifiers.
errID = 'imaq:imaqcallback:invalidSyntax';
errID2 = 'imaq:imaqcallback:zeroInputs';

switch nargin
    case 0
        error(message(errID2));
    case 1
        error(message(errID));
    case 2
        if ~isa(obj, 'imaqdevice') || ~isa(event, 'struct')
            error(message(errID));
        end
        if ~(isfield(event, 'Type') && isfield(event, 'Data'))
            error(message(errID));
        end
end

% Determine the type of event.
EventType = event.Type;

% Determine the time of the error event.
EventData = event.Data;
EventDataTime = EventData.AbsTime;

% Create a display indicating the type of event, the time of the event and
% the name of the object.
name = get(obj, 'Name');
fprintf('%s event occurred at %s for video input object: %s.\n', ...
    EventType, datestr(datetime(EventDataTime),13), name);

% Display the error string.
if strcmpi(EventType, 'error')
    fprintf('%s\n', EventData.Message);
end


if strcmpi(event.Data.MessageID,'imaq:imaqmex:outofmemory')
    msgbox('Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
    msgbox('Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end