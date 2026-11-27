function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_bitflow_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode,n_cameras)
% Prepare one OPTRONIS Cyclone on the BitFlow grabber, or two for stereo acquisition (n_cameras = 2, both on
% the camera output of the synchronizer), for synced PIV capture. OPTRONIS_vid: cell array with one
% videoinput per camera ({1} = camera 1). After this function, the cameras wait for the external trigger.
if nargin < 5
    n_cameras = 1;
end
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
OutputError=0;
frame_nr_display=[];

%% select bitmode
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end
if bitmode==8
    camfilemode='PIVMode8bit'; % funktioniert ohne Fehlermeldung, timing + dropped frames nicht kontrolliert.
else
    camfilemode='PIVMode10bit';
end
%% select cam subtype
camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, '25-150')
    exposure_gap = 24;
elseif contains(camera_sub_type, '2-2000')
    exposure_gap = 3;
elseif contains(camera_sub_type, '1HS-3500')
    exposure_gap = 3;
else
    disp('bfml file does not exist for this camera type')
    OutputError=1;
    OPTRONIS_vid={};
    return
end
if bitmode > 8
    exposure_gap = exposure_gap + 1; %maximum exposure issmaller at 10 bit
end

if isinf(nr_of_images) %PIV preview
    buffers_needed = 125;
else
    buffers_needed = nr_of_images*2 / 4 ; % one quarter of images RAM buffer
end

%% Prepare cameras
imaqreset
[OPTRONIS_vid,imaq_error] = PIVlab_capture_OPTRONIS_bitflow_open(camfilemode,n_cameras,buffers_needed);
if imaq_error ~= 0
    OutputError=1;
    OPTRONIS_vid={};
    return
end

%% camera settings (stereo: the same settings for both cameras)
ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
fps_too_high=0;
for k=1:n_cameras
    if configure_synced(OPTRONIS_vid{k},ROI_OPTRONIS,frame_rate,exposure_gap) == 0
        fps_too_high=1;
    end
end
if fps_too_high==1
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Frame rate too high','The frame rate is too high for the current configuration, please reduce it.', 'modal');
end

%% prepare axes
%image objects for acquisition.show_frame (drawn at screen resolution, sharp when zoomed); stereo side by side
[image_handles,frame_nr_display] = acquisition.live_images(n_cameras,[ROI_OPTRONIS(3) ROI_OPTRONIS(4)],2^bitmode);
setappdata(hgui,'image_handles_OPTRONIS',image_handles);
setappdata(hgui,'image_handle_OPTRONIS',image_handles{1});

if fps_too_high==0
    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame+2;
    for k=1:n_cameras
        OPTRONIS_src = OPTRONIS_vid{k}.Source;
        OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
        OPTRONIS_src.BFGTLNodeValueStr = 'Off';
        OPTRONIS_vid{k}.FramesPerTrigger = OPTRONIS_frames_to_capture;
        if ~isinf(nr_of_images) %PIV capture
            prewarm(OPTRONIS_vid{k},OPTRONIS_frames_to_capture);
        end
        OPTRONIS_vid{k}.ErrorFcn = @CustomIMAQErrorFcn;
    end
    %No preview(): synced_capture shows the frames via peekdata (displaying the full frames at a
    %high rate causes skipped frames and a high CPU load). In PIV preview (nr_of_images = Inf,
    %FramesPerTrigger = Inf), synced_capture discards the frames continuously.

    for k=1:n_cameras
        tmp=get(image_handles{k},'CData');
        tmp=size(tmp(:,:,1));
        set(image_handles{k},'CData',ones(tmp)*35);
    end
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);
    pause(0.01)
    caxis([0 2^bitmode]);

    %%% Variante mit manuellem trigger
    for k=1:n_cameras
        triggerconfig(OPTRONIS_vid{k}, 'manual'); %so recording starts only when (trigger(OPTR... is called
        start(OPTRONIS_vid{k});
    end
    pause(0.2)
    for k=1:n_cameras
        trigger(OPTRONIS_vid{k}) %also in PIV preview: frames must be logged for peekdata
    end
    pause(0.1)
    drawnow;
    %Here: capture is running, waiting for external trigger input.
end

function ok = configure_synced(OPTRONIS_vid,ROI_OPTRONIS,frame_rate,exposure_gap)
%exposure, counter, gain, ROI and frame rate of one camera; ok = 0: the camera refused the frame rate
OPTRONIS_src = OPTRONIS_vid.Source;
%% Set exposure time
exposure_time = ceil(1/frame_rate*1000^2 - exposure_gap);
OPTRONIS_src.BFGTLNodeName = 'ExposureTime';
OPTRONIS_src.BFGTLNodeValueStr = num2str(round(exposure_time));

%% Counter and gain settings
OPTRONIS_gain = gui.camera_setting('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end

OPTRONIS_counter = gui.camera_setting('OPTRONIS_counter');
if isempty(OPTRONIS_counter)
    OPTRONIS_counter=1;
end

if OPTRONIS_counter==0
    OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
    OPTRONIS_src.BFGTLNodeValueStr = 'Off';
elseif OPTRONIS_counter==1
    OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
    OPTRONIS_src.BFGTLNodeValueStr = 'On';
end

OPTRONIS_src.BFGTLNodeName     = 'AGain';
OPTRONIS_src.BFGTLNodeValueStr = num2str(OPTRONIS_gain);

%% Set ROI
%ROI_OPTRONIS(3) = max(64, floor(ROI_OPTRONIS(3)/64)*64); % width must be multiple of 64 (4 CXP links × 16-pixel quantum)
OPTRONIS_src.BFGTLNodeName     = 'OffsetX'; % zero offsets before changing size to avoid constraint violations
OPTRONIS_src.BFGTLNodeValueStr = '0';
OPTRONIS_src.BFGTLNodeName     = 'OffsetY';
OPTRONIS_src.BFGTLNodeValueStr = '0';
OPTRONIS_src.BFGTLNodeName     = 'Width';
OPTRONIS_src.BFGTLNodeValueStr = num2str(ROI_OPTRONIS(3));
OPTRONIS_src.BFGTLNodeName     = 'Height';
OPTRONIS_src.BFGTLNodeValueStr = num2str(ROI_OPTRONIS(4));
OPTRONIS_src.BFGTLNodeName     = 'OffsetX';
OPTRONIS_src.BFGTLNodeValueStr = num2str(ROI_OPTRONIS(1));
OPTRONIS_src.BFGTLNodeName     = 'OffsetY';
OPTRONIS_src.BFGTLNodeValueStr = num2str(ROI_OPTRONIS(2));
% VideoResolution stays at the BFML default (sensor size); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% Set frame rate (check if too high). The camera limits it to what its CoaXPress links can transfer
%% (Cyclone-2-2000-M full frame 8 bit: 2160 fps with four links, 1087 fps with two links in stereo).
ok=1;
try
    OPTRONIS_src.BFGTLNodeName     = 'AcquisitionFrameRate';
    OPTRONIS_src.BFGTLNodeValueStr = num2str(round(frame_rate));
    set_frame_rate = str2double(OPTRONIS_src.BFGTLNodeValueStr);
    if set_frame_rate ~= round(frame_rate)
        ok=0;
    end
catch
    ok=0;
end

function prewarm(OPTRONIS_vid,OPTRONIS_frames_to_capture)
% Pre-warm: 2 frames with internal trigger (Continuous mode), discard
% Ensures the CXP/DMA pipeline and camera state machine are fully initialised
% before the real triggered acquisition, preventing the first-frame skip.
disp('prewarm start')
OPTRONIS_src = OPTRONIS_vid.Source;
OPTRONIS_src.BFGTLNodeName     = 'AcquisitionStop';   % put camera in Idle (makes AcquisitionMode writable)
OPTRONIS_src.BFGTLNodeValueStr = '1';                 % '1' executes a GenICam command node
pause(0.01)
OPTRONIS_src.BFGTLNodeName     = 'AcquisitionMode';
OPTRONIS_src.BFGTLNodeValueStr = 'Continuous';
OPTRONIS_vid.FramesPerTrigger  = 2;
triggerconfig(OPTRONIS_vid, 'immediate');
start(OPTRONIS_vid);
wait(OPTRONIS_vid, 5);             % 2 frames @ 100 fps = 20 ms; 5 s is a safe ceiling
stop(OPTRONIS_vid);                % sends AcquisitionStop -> camera back to Idle
flushdata(OPTRONIS_vid);           % discard warm-up frames
pause(0.01)
% Restore SingleFrame + external trigger for the real acquisition
OPTRONIS_src.BFGTLNodeName     = 'AcquisitionMode';
OPTRONIS_src.BFGTLNodeValueStr = 'SingleFrame';
OPTRONIS_vid.FramesPerTrigger  = OPTRONIS_frames_to_capture;
pause(0.1);
disp('prewarm stop')

function CustomIMAQErrorFcn(obj, event, varargin)
stop(obj)
hgui=getappdata(0,'hgui');
setappdata(hgui,'cancel_capture',1)

errID  = 'imaq:imaqcallback:invalidSyntax';
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
