function [OutputError,OPTOcam_vid,frame_nr_display,max_pair_rate] = PIVlab_capture_OPTOcam_20_9_synced_start(nr_of_images,ROI_OPTOcam,frame_rate,bitmode,exposure1)
% Prepare the OPTOcam 20/9 for synced double-frame PIV capture using the sensor's
% native double-frame (mvPivShutter) mode. ONE external trigger on Line4 makes the
% sensor expose frame A (short, = exposure1) then frame B (long, automatic), i.e. one
% trigger -> one image pair (double_shutter principle, like the pco cameras). The
% synchronizer therefore sends nr_of_images trigger pulses and the camera delivers
% nr_of_images*2 frames (A,B,A,B,...), saved later as _A/_B pairs.
%
% frame_rate here is the image-PAIR rate (pairs/s), consistent with the fps popup.
% max_pair_rate is the highest achievable pair rate for the current ROI / bit depth (pairs/s),
% read from the camera BEFORE the double-frame mode is enabled (see below); the caller
% must use this value and not query mvResultingFrameRate itself.
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled'); %#ok<NASGU>
sharpness_enabled = getappdata(hgui,'sharpness_enabled'); %#ok<NASGU>
OutputError=0;
max_pair_rate=inf;

%% Prepare camera
imaq_error=0;
try
    delete(imaqfind); %clears all previous videoinputs
    warning off
    hwinf = imaqhwinfo;
catch
    imaq_error=1;
end
warning('off','imaq:gentl:noSupportedPixelFormat')
if imaq_error==0
    if isempty(hwinf.InstalledAdaptors)
        imaq_error=2;
    end
end
if imaq_error==0
    found_correct_adaptor=0;
    for adaptorID=1:numel(hwinf.InstalledAdaptors)
        info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
        if strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq')
            found_correct_adaptor=1;
            imaq_error=0;
            break
        else
            imaq_error=2;
        end
    end
end
if imaq_error==0 && found_correct_adaptor ==1
    try
        %Identify the camera by the OEM USB Vendor ID in its enumerated device name (fast, no camera opened).
        found_cam=0;
        for CamID = 1: size(info.DeviceInfo,2)
            if contains(info.DeviceInfo(CamID).DeviceName,'VID164C','IgnoreCase',true)
                found_cam=1;
                break
            end
        end
        if found_cam
            OPTOcam_name = 'OPTOcam 20/9';
        else
            imaq_error=3;
        end
    catch
        imaq_error=3;
    end
end
if imaq_error==1
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
elseif imaq_error==2
    disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
    disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, support package missing',{'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'modal');
elseif imaq_error==3
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected?','modal');
end
if imaq_error~=0
    OutputError=1; OPTOcam_vid=[]; frame_nr_display=[]; max_pair_rate=inf;
    return
end
disp(['Found camera: ' OPTOcam_name])

%% open in requested bit depth
if bitmode==8
    OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,'Mono8');
elseif bitmode==12
    OPTOcam_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,'Mono12p'); %packed 12 bit -> higher frame rate than Mono12
end

OPTOcam_settings = get(OPTOcam_vid);
%Use the full USB3 bandwidth (no artificial throughput limit). The measured max pair rate depends
%on ROI/bit depth; the settings check below warns if the requested rate is not achievable.
try
    OPTOcam_settings.Source.DeviceLinkThroughputLimitMode = 'Off';
catch
end
OPTOcam_settings.PreviewFullBitDepth='On';
OPTOcam_vid.PreviewFullBitDepth='On';

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
OPTOcam_climits=2^bitmode;
image_handle_OPTOcam=imagesc(zeros(ROI_OPTOcam(4),ROI_OPTOcam(3)),'Parent',PIVlab_axis,[0 OPTOcam_climits]);
setappdata(hgui,'image_handle_OPTOcam_20_9',image_handle_OPTOcam);

frame_nr_display=text(PIVlab_axis,100,100,'Initializing...','Color',[1 1 0]);
colormap(ancestor(PIVlab_axis,'figure'),'default') %reset colormap steps
new_map=colormap(ancestor(PIVlab_axis,'figure'),'gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(ancestor(PIVlab_axis,'figure'),new_map);axis(PIVlab_axis,'image');
set(PIVlab_axis,'ytick',[])
set(PIVlab_axis,'xtick',[])
colorbar(PIVlab_axis)

%% ROI (0-based offset for the camera, like the pco/OPTOcam convention)
ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)];
OPTOcam_vid.ROIPosition=ROI_OPTOcam;

%orientation: default (no mirroring). Flip here if the image is mirrored on the rig.
OPTOcam_settings.Source.ReverseX = 'False';
OPTOcam_settings.Source.ReverseY = 'False';

OPTOcam_gain = getappdata(hgui,'OPTOcam_20_9_gain');
if isempty (OPTOcam_gain)
    OPTOcam_gain=0;
end
OPTOcam_settings.Source.Gain = OPTOcam_gain;

%% first-frame (A) exposure.
%The value is produced by the shared timing model (PIVlab_capture_OPTOcam_20_9_timing.m): it is
%chosen so that laser pulse 1 fits into frame 1 AND so that the camera's exposure quantisation
%stays predictable (the setting sits in the middle of a quantisation plateau).
if nargin < 5 || isempty(exposure1)
    exposure1 = 60; %us, lands in the minimum (123.5 us) frame-1 exposure plateau
end
exposure1 = max(7, min(2522, exposure1)); %settable ExposureTime range (measured on the rig)
OPTOcam_settings.Source.mvShutterMode = 'mvGlobalShutter'; %single-frame mode for the frame-rate query below
OPTOcam_settings.Source.ExposureMode  = 'Timed';
OPTOcam_settings.Source.TriggerMode   = 'Off';
OPTOcam_settings.Source.ExposureTime  = exposure1;

%% maximum achievable pair rate for the current ROI / bit depth
%mvResultingFrameRate is only re-evaluated by the camera in single-frame (mvGlobalShutter) mode.
%Once mvPivShutter is active the node FREEZES at its last value (measured: exposure changes are
%ignored, so it would still report the rate of the long live-image exposure). It is therefore
%read here, with ROI/bit depth/exposure already applied but BEFORE the double-frame mode is
%switched on. The value is the readout-limited single-frame rate; in double-frame mode the camera
%delivers exactly that many single frames per second (measured), i.e. half as many image pairs.
try
    max_pair_rate = get(OPTOcam_vid.Source,'mvResultingFrameRate')/2; %2 frames per image pair
    disp(['Maximum image-pair rate with current settings: ' num2str(round(max_pair_rate,1)) ' pairs/s.'])
catch
    max_pair_rate = inf;
end
disp(['Requested image-pair rate: ' num2str(frame_rate) ' pairs/s.']);

%% double-frame (mvPivShutter) + hardware trigger on Line4
triggerconfig(OPTOcam_vid, 'hardware');
OPTOcam_settings.Source.mvShutterMode  = 'mvPivShutter'; %sensor-native double frame (one trigger -> pair)
OPTOcam_settings.Source.TriggerSelector= 'FrameStart';
OPTOcam_settings.Source.TriggerSource  = 'Line4';       %external trigger input from the synchronizer
OPTOcam_settings.Source.TriggerActivation = 'RisingEdge';
OPTOcam_settings.Source.TriggerMode    = 'On';
OPTOcam_settings.Source.ExposureTime   = exposure1;     %re-apply: the mode switch clamps ExposureTime to its double-frame range

%% Line0 = ExposureActive output (used to measure timings/delays on the rig)
OPTOcam_settings.Source.LineSelector = 'Line0';
OPTOcam_settings.Source.LineSource   = 'ExposureActive';
OPTOcam_settings.Source.LineInverter = 'False';

%% Line1 = AcquisitionActive output (used to signal activity on the camera LED and to turn off the fan)
OPTOcam_settings.Source.LineSelector = 'Line1';
OPTOcam_settings.Source.LineSource   = 'AcquisitionActive';
OPTOcam_settings.Source.LineInverter = 'False';

%% start acquisition (waiting for external triggers)
OPTOcam_frames_to_capture = nr_of_images*2; %2 frames (A,B) per pair
OPTOcam_vid.FramesPerTrigger = OPTOcam_frames_to_capture;
if ~isinf(nr_of_images) %only start capturing if save box is ticked.
    flushdata(OPTOcam_vid);
    OPTOcam_vid.ErrorFcn = @CustomIMAQErrorFcn;
    start(OPTOcam_vid);
end

%Frames arrive as A,B,A,B... and frame B (long fixed exposure) is much brighter with ambient
%light, so a plain preview would flicker. The callback shows frame A only (B via the A/B toggle),
%see PIVlab_capture_OPTOcam_20_9_preview_update.m
setappdata(image_handle_OPTOcam,'OPTOcam_20_9_ab_state',[]);
setappdata(image_handle_OPTOcam,'UpdatePreviewWindowFcn',@PIVlab_capture_OPTOcam_20_9_preview_update);
preview(OPTOcam_vid,image_handle_OPTOcam);
if bitmode ==8
    caxis(PIVlab_axis,[0 2^8]); %workaround to force preview to show full data range
elseif bitmode==12
    caxis(PIVlab_axis,[0 2^12]);
end
pause(0.1);
if ~isinf(nr_of_images)
    status=[];
    while isempty(status) %make sure OPTOcam is ready...
        status=OPTOcam_vid.Eventlog;
        pause(0.001)
    end
end
drawnow;
pause(0.05)

function CustomIMAQErrorFcn(obj, event, varargin)
stop(obj)
hgui=getappdata(0,'hgui');
setappdata(hgui,'cancel_capture',1)

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

EventType = event.Type;
EventData = event.Data;
EventDataTime = EventData.AbsTime;
name = get(obj, 'Name');
fprintf('%s event occurred at %s for video input object: %s.\n', ...
    EventType, datestr(datetime(EventDataTime),13), name);
if strcmpi(EventType, 'error')
    fprintf('%s\n', EventData.Message);
end
if strcmpi(event.Data.MessageID,'imaq:imaqmex:outofmemory')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Memory full','Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end
