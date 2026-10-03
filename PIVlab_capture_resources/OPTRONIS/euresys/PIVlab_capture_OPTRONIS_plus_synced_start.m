function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_plus_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode)
%Optronis CyclonePlus cameras on the Euresys grabber (gentl adaptor).
%Differences to the Cyclone cameras (PIVlab_capture_OPTRONIS_synced_start.m):
% - The trigger is configured from Matlab: TriggerMode On, TriggerSource Line1 (synchronizer cable at the camera I/O).
% - triggerconfig must be 'hardware'. With 'manual' or 'immediate', the gentl adaptor switches TriggerMode Off
%   at start() and preview(), and the camera would free run.
% - AcquisitionFrameRate is read-only while TriggerMode is On. The max. frame rate is read with TriggerMode Off.
% - Property names: Gain (dB), OptrImageStamp, OptrEnableFan.
%
%Adding another CyclonePlus model requires a new entry in:
% - the camera model section of PIVlab_capture_OPTRONIS_plus_synced_start.m and PIVlab_capture_OPTRONIS_plus_calibration_image.m
% - PIVlab_capture_OPTRONIS_cam_detect.m (camera_sub_type)
% - +acquisition/select_capture_config_Callback.m (frame rates, resolution)
% - +acquisition/piv_capture_Callback.m (max. frame rate)
% - PIVlab_calc_oltsync_timings.m (blind time, camera delay)
% - +acquisition/calibROI_Callback.m and +roi/setdefaultroi.m (ROI presets)
%For the BitFlow grabber additionally ('-bitflow' sub type, e.g. 'CyclonePlus-25-M-bitflow'):
% - the camera model section of PIVlab_capture_OPTRONIS_plus_bitflow_synced_start.m and PIVlab_capture_OPTRONIS_plus_bitflow_calibration_image.m (bfml file)
% - PIVlab_capture_OPTRONIS_bitflow_cam_detect.m (camera_sub_type), PIVlab_capture_OPTRONIS_bitflow_settings_GUI.m (bfml file)
% - +acquisition/select_capture_config_Callback.m and PIVlab_calc_oltsync_timings.m ('-bitflow' case)
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
OutputError=0;

%% Prepare camera
delete(imaqfind); %clears all previous videoinputs
try
    hwinf = imaqhwinfo;
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
end

found_correct_adaptor=0;
for adaptorID=1:numel(hwinf.InstalledAdaptors)
    info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
    if strcmp(info.AdaptorName,'gentl')
        disp(['gentl adaptor found with ID: ' num2str(adaptorID)])
        found_correct_adaptor=1;
        break
    end
end

if found_correct_adaptor~=1
    disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
    disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, support package missing',{'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'modal');
end

try
    %Getting camera device ID when multiple cameras are connected
    for CamID = 1: size(info.DeviceInfo,2)
        camName=info.DeviceInfo(CamID).DeviceName;
        if contains(camName,'CyclonePlus')
            break
        end
    end
    OPTRONIS_name = info.DeviceInfo(CamID).DeviceName;
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected?','modal');
end

%% camera model specific settings
settings_ok=1;
if contains(OPTRONIS_name,'CyclonePlus-25-M')
    disp(['Found camera: ' 'CyclonePlus-25-M'])
    exposure_gap=24; %time between end of exposure and next trigger (us). Same as in free run: max. exposure = 1/fps - 24 us
    max_expo=50000; %max. exposure time in trigger mode (us)
    min_expo=8; %min. exposure time (us)
else
    disp('camera type unknown!')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',['Camera type unknown: ' OPTRONIS_name],'modal');
    settings_ok=0;
end
warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning

% select bitmode (some support 8, 10, 12 bits)
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end
if verLessThan('matlab','25') %if not 2025a and beyond: force to be 8 bit, because not supported by matlab.
    bitmode =8;
end
OPTRONIS_vid = videoinput(info.AdaptorName,info.DeviceInfo(CamID).DeviceID,['Mono' sprintf('%0.0d',bitmode)]);
OPTRONIS_vid.PreviewFullBitDepth='On';
OPTRONIS_vid.UserData=struct('frame_rate',frame_rate); %needed in PIVlab_capture_OPTRONIS_plus_save (AcquisitionFrameRate can not be read in trigger mode)
OPTRONIS_src=getselectedsource(OPTRONIS_vid);

OPTRONIS_gain = gui.retr('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end
OPTRONIS_src.Gain = 20*log10(OPTRONIS_gain); %gain in dB, GUI gain is a factor (1, 2, 4)

OPTRONIS_counter = gui.retr('OPTRONIS_counter');
if isempty(OPTRONIS_counter)
    OPTRONIS_counter=1;
end
if OPTRONIS_counter==0
    OPTRONIS_src.OptrImageStamp = 'Off';
elseif OPTRONIS_counter ==1
    OPTRONIS_src.OptrImageStamp = 'On';
end

ROI_OPTRONIS=[ROI_OPTRONIS(1)-1,ROI_OPTRONIS(2)-1,ROI_OPTRONIS(3),ROI_OPTRONIS(4)];
OPTRONIS_vid.ROIPosition=ROI_OPTRONIS; %must be set before the max. frame rate is read, and before start

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
OPTRONIS_climits=2^bitmode;
image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 OPTRONIS_climits]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);

frame_nr_display=text(PIVlab_axis,100,100,'Initializing...','Color',[1 1 0]);
colormap(ancestor(PIVlab_axis,'figure'),'default') %reset colormap steps
new_map=colormap(ancestor(PIVlab_axis,'figure'),'gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(ancestor(PIVlab_axis,'figure'),new_map);axis(PIVlab_axis,'image');
set(PIVlab_axis,'ytick',[])
set(PIVlab_axis,'xtick',[])

colorbar(PIVlab_axis)

%% max. frame rate for this ROI (can only be read with TriggerMode Off)
if settings_ok==1
    OPTRONIS_src.TriggerMode = 'Off';
    fps_limits = propinfo(OPTRONIS_src,'AcquisitionFrameRate').ConstraintValue;
    if frame_rate > fps_limits(2)
        uiwait(errordlg(['The frame rate is too high for the selected FOV. With the current settings, the frame rate must not be higher than ' num2str(fps_limits(2)) ' fps.'],'Frame rate error'))
        settings_ok=0;
    end
end

%% set camera parameters for triggered acquisition
if settings_ok==1
    %one frame per rising edge of the synchronizer signal on Line1
    OPTRONIS_src.TriggerSelector = 'ExposureStart';
    OPTRONIS_src.TriggerMode = 'On';
    OPTRONIS_src.TriggerSource = 'Line1';
    OPTRONIS_src.TriggerActivation = 'RisingEdge';
    OPTRONIS_src.ExposureMode = 'Timed';
    triggerconfig(OPTRONIS_vid, 'hardware','DeviceSpecific','DeviceSpecific'); %'manual' would switch TriggerMode Off
    exposure_time=ceil(1/frame_rate*1000^2-exposure_gap);
    exposure_time=min(max(exposure_time,min_expo),max_expo);
    OPTRONIS_src.ExposureTime=exposure_time;

    %% start acqusition (waiting for trigger)
    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
    OPTRONIS_vid.FramesPerTrigger = OPTRONIS_frames_to_capture+2;
    %Recording and PIV preview both log frames. synced_capture shows downsampled frames via peekdata
    %(no preview(): displaying the full frames at a high rate causes skipped frames and a high CPU load).
    %In PIV preview (nr_of_images = Inf, FramesPerTrigger = Inf), synced_capture discards the frames continuously.
    flushdata(OPTRONIS_vid);
    pause(0.01)
    OPTRONIS_vid.ErrorFcn = @CustomIMAQErrorFcn;
    if ~isinf(nr_of_images)
        OPTRONIS_src.OptrEnableFan = 'Off';
    end
    %hardware trigger: logging starts with the first synchronizer pulse
    start(OPTRONIS_vid);
    tmp=get(image_handle_OPTRONIS,'CData');
    tmp=size(tmp(:,:,1));
    set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);
    caxis([0 2^bitmode]); %seems to be a workaround to force preview to show full data range...
    drawnow;
else
    setappdata(hgui,'cancel_capture',1) %nothing will be captured
end

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
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Memory full','Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end
