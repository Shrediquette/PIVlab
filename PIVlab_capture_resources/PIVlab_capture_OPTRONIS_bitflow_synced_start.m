function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_bitflow_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode)
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
OutputError=0;

disp('Settings:')
nr_of_images
ROI_OPTRONIS
frame_rate
bitmode

%% Prepare camera
delete(imaqfind); %clears all previous videoinputs
try
    hwinf = imaqhwinfo; %#ok<NASGU>
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
end

found_correct_adaptor=0;
for adaptorID=1:numel(hwinf.InstalledAdaptors)
    info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
    if strcmp(info.AdaptorName,'bitflow')
        disp(['bitflow adaptor found with ID: ' num2str(adaptorID)])
        found_correct_adaptor=1;
        break
    end
end

if found_correct_adaptor~=1
    disp('ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB adaptor.')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, adaptor missing','ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB IMAQ adaptor.','modal');
    OutputError=1;
    OPTRONIS_vid=[];
    frame_nr_display=[];
    return
end

%% Create videoinput
bfml_dir  = fileparts(mfilename('fullpath'));

% select bitmode
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end

camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, '25-150')
    if bitmode==8
        bfml_name = 'Optronis-Cyclone-25-150-M.bfml';
    else
        bfml_name = 'Optronis-Cyclone-25-150-M-10bit.bfml';
    end
else
    if bitmode==8
        bfml_name = 'Optronis-Cyclone-2-2000-M.bfml';
    else
        bfml_name = 'Optronis-Cyclone-2-2000-M-10bit.bfml';
    end
end
bfml_path = fullfile(bfml_dir, bfml_name);
if isinf(nr_of_images)
    buffers_needed = 125;
else
    buffers_needed = nr_of_images*2 + fix_Optronis_skipped_frame + 2 + 150;
end
'buufers werden reduziert.'
buffers_needed=round(buffers_needed/4) %/4 funktioniert bei 15000 bildpaaren und 2000 Hz

OPTRONIS_vid = videoinput('bitflow', 1, [bfml_path ';BuffersToUse=' num2str(buffers_needed)]);
OPTRONIS_src = getselectedsource(OPTRONIS_vid);

% FIRST thing: stop the camera before start() is called.
% The BFML 'Default' mode sends AcquisitionStart=1 as an after_setup command
% during videoinput() creation, so the camera is already firing. The DMA ring
% (BuffersToUse) only starts filling when start() is called. Sending
% AcquisitionStop here — BEFORE start() — ensures the ring is empty at
% trigger() time, so only the actual capture frames consume buffer slots.
OPTRONIS_src.BFGTLNodeName     = 'AcquisitionStop';
OPTRONIS_src.BFGTLNodeValueStr = '1';

%% Read camera model name to determine per-model constants
try
    OPTRONIS_src.BFGTLNodeName = 'DeviceModelName';
    OPTRONIS_name = OPTRONIS_src.BFGTLNodeValueStr;
catch
    OPTRONIS_name = 'Cyclone-2-2000-M';
end

%% Per-model constants
if contains(OPTRONIS_name,'2000')
    disp(['Found camera: Cyclone-2-2000-M'])
    exposure_gap = 3;
    minexpo = 2;
elseif contains(OPTRONIS_name,'3500') || contains(OPTRONIS_name,'1HS')
    disp(['Found camera: Cyclone-1HS-3500-M'])
    exposure_gap = 3;
    minexpo = 2;
elseif contains(OPTRONIS_name,'25-150') || contains(OPTRONIS_name,'25150')
    disp(['Found camera: Cyclone-25-150-M'])
    exposure_gap = 24;
    minexpo = 12;
else
    disp(['camera type unknown: ' OPTRONIS_name])
    exposure_gap = 3;
    minexpo = 2;
end
if bitmode > 8
    exposure_gap = exposure_gap + 1;
end
exposure_time = ceil(1/frame_rate*1000^2 - exposure_gap)

%% Read user settings
OPTRONIS_gain = gui.retr('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end

OPTRONIS_counter = gui.retr('OPTRONIS_counter');
if isempty(OPTRONIS_counter)
    OPTRONIS_counter=1;
end

%% Set pixel format
if bitmode==8
    OPTRONIS_src.BFGTLNodeName     = 'PixelFormat';
    OPTRONIS_src.BFGTLNodeValueStr = 'Mono8';
elseif bitmode==10
    OPTRONIS_src.BFGTLNodeName     = 'PixelFormat';
    OPTRONIS_src.BFGTLNodeValueStr = 'Mono10';
end

%% Set ROI
ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
ROI_OPTRONIS(3) = max(64, floor(ROI_OPTRONIS(3)/64)*64); % width must be multiple of 64 (4 CXP links × 16-pixel quantum)
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
% VideoResolution stays at the BFML default (1920×1080); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% prepare axes
PIVlab_axis = findobj(hgui,'Type','Axes');
OPTRONIS_climits=2^bitmode;
image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 OPTRONIS_climits]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gui.retr('pivlab_axis'),'ytick',[])
set(gui.retr('pivlab_axis'),'xtick',[])
colorbar

%% Set acquisition mode and frame rate
OPTRONIS_src.BFGTLNodeName     = 'AcquisitionMode';
OPTRONIS_src.BFGTLNodeValueStr = 'SingleFrame';

if ~verLessThan('matlab','25')
    OPTRONIS_src.BFGTLNodeName     = 'MaxFrameRateExtended';
    OPTRONIS_src.BFGTLNodeValueStr = 'Extended';
end

%% Set exposure
OPTRONIS_src.BFGTLNodeName     = 'ExposureMode';
OPTRONIS_src.BFGTLNodeValueStr = 'Timed';

OPTRONIS_src.BFGTLNodeName     = 'ExposureTime';
OPTRONIS_src.BFGTLNodeValueStr = num2str(minexpo);  % set min first so high frame rate is accepted

%% Set frame rate (check if too high)
fps_too_high=0;
lastwarn('');
try
    OPTRONIS_src.BFGTLNodeName     = 'AcquisitionFrameRate';
    OPTRONIS_src.BFGTLNodeValueStr = num2str(frame_rate);
catch ME
    try
        msg=strsplit(ME.message,'value must be less than or equal to ');msg{2}(end)=[];msg=msg{2};
    catch
        msg = '(can not determine max. frame rate)';
    end
    uiwait(errordlg(['The frame rate is too high for the selected FOV. With the current settings, the frame rate must not be higher than ' msg ' fps.'],'Frame rate error'))
    fps_too_high=1;
end
if fps_too_high==0
    [w, ~] = lastwarn;
    if ~isempty(w)
        % Camera issued a warning (not a thrown error) — typical for BitFlow/GenICam OutOfRange.
        % In 10-bit mode (Mono10 = 16 bit/pixel) the CXP bandwidth limits the achievable frame rate.
        max_fps_10bit = floor(4*12.5e9 / (ROI_OPTRONIS(3)*ROI_OPTRONIS(4)*16));
        uiwait(errordlg(sprintf(['The frame rate %g fps is too high for the current pixel format (%d-bit) ' ...
            'and resolution (%d x %d).\n\nIn 10-bit mode each pixel occupies 2 bytes, halving the ' ...
            'maximum frame rate compared to 8-bit mode.\n\nMaximum frame rate at this resolution: ' ...
            '~%d fps.\n\nPlease reduce the frame rate in the settings.'], ...
            frame_rate, bitmode, ROI_OPTRONIS(3), ROI_OPTRONIS(4), max_fps_10bit), 'Frame rate error'))
        fps_too_high=1;
    end
end

if fps_too_high==0
    %% Counter and gain settings
    if OPTRONIS_counter==0
        OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
        OPTRONIS_src.BFGTLNodeValueStr = 'Off';
    elseif OPTRONIS_counter==1
        OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
        OPTRONIS_src.BFGTLNodeValueStr = 'On';
    end

    OPTRONIS_src.BFGTLNodeName     = 'AGain';
    OPTRONIS_src.BFGTLNodeValueStr = num2str(OPTRONIS_gain);

    %% Configure external trigger via camera Sync In connector
    % This camera has no standard GenICam TriggerMode node. SyncInActivation sets
    % the edge polarity of the Sync In pin; the camera always runs at AcquisitionFrameRate
    % and each frame's exposure is timed to the Sync In pulse.
    bf_set(OPTRONIS_src, 'SyncInActivation', 'RisingEdge');

    OPTRONIS_src.TriggerMode = 'Free Run'; % board (IMAQ) captures all frames from camera

    %% Turn fan off during acquisition to reduce vibration
    OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
    OPTRONIS_src.BFGTLNodeValueStr = 'Off';

    % NOTE: AcquisitionStart=1 is deliberately deferred to just before
    % trigger() below. If sent here, the camera would fire continuously
    % at the SyncIn rate throughout start(), preview(), and the bf_set
    % round-trips that follow, filling the DMA buffer pool with frames
    % that nobody is consuming yet. At 1000 fps that consumed ~1000
    % extra buffers during setup before trigger() could begin.

    %% Start acquisition (waiting for trigger)
    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
    % FramesPerTrigger=Inf: IMAQ engine never auto-stops at a frame-count
    % boundary. The synced_capture while loop controls termination by
    % checking FramesAcquired, then explicitly issues AcquisitionStop=1
    % and stop(). Auto-stopping at FramesPerTrigger caused buffer
    % exhaustion warnings because the camera kept firing after IMAQ
    % stopped consuming.
    OPTRONIS_vid.FramesPerTrigger = nr_of_images*2 + 2;
    triggerconfig(OPTRONIS_vid, 'manual');

    if ~isinf(nr_of_images)
        flushdata(OPTRONIS_vid);
        pause(0.01)
        OPTRONIS_vid.ErrorFcn = @CustomIMAQErrorFcn;
        start(OPTRONIS_vid);
    end

    if bitmode > 8
        set(OPTRONIS_vid, 'PreviewFullBitDepth', 'on');
    end
    preview(OPTRONIS_vid, image_handle_OPTRONIS);
    tmp=get(image_handle_OPTRONIS,'CData');
    tmp=size(tmp(:,:,1));
    set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);

    %% Set final frame rate and exposure time (use bf_set so silent rejections are visible)
    bf_set(OPTRONIS_src, 'AcquisitionFrameRate', num2str(frame_rate));
    bf_set(OPTRONIS_src, 'ExposureTime',          num2str(exposure_time));

    %% Verify active settings read back from camera
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionFrameRate';
    disp(['  AcquisitionFrameRate (active) = ' OPTRONIS_src.BFGTLNodeValueStr ' fps']);
    OPTRONIS_src.BFGTLNodeName = 'ExposureTime';
    disp(['  ExposureTime         (active) = ' OPTRONIS_src.BFGTLNodeValueStr ' µs']);
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionMode';
    disp(['  AcquisitionMode      (active) = ' OPTRONIS_src.BFGTLNodeValueStr]);
    OPTRONIS_src.BFGTLNodeName = 'SyncInActivation';
    disp(['  SyncInActivation     (active) = ' OPTRONIS_src.BFGTLNodeValueStr]);

    pause(0.01)

    caxis([0 2^bitmode]);
    drawnow;

    %% Restart camera immediately before trigger so the DMA ring contains
    %% only the actual capture frames (no pre-trigger accumulation).
    OPTRONIS_src.BFGTLNodeName     = 'AcquisitionStart';
    OPTRONIS_src.BFGTLNodeValueStr = '1';

    if ~isinf(nr_of_images)
        trigger(OPTRONIS_vid)
    end
 
end

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

'lalalla'
fprintf('%s\n', EventData.Message);
'lalalla'

if strcmpi(event.Data.MessageID,'imaq:imaqmex:outofmemory')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Memory full','Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end

function bf_set(src, name, value)
lastwarn('');
src.BFGTLNodeName     = name;
src.BFGTLNodeValueStr = value;
[w, wid] = lastwarn;
if ~isempty(w)
    fprintf('*** BFGTLNode warning: %-30s = %-20s  [%s]\n', name, value, wid);
end

