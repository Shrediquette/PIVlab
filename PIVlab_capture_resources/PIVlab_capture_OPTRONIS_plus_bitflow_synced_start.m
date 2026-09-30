function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_plus_bitflow_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode)
%Optronis CyclonePlus cameras on the BitFlow grabber (bitflow adaptor).
%Based on PIVlab_capture_OPTRONIS_bitflow_synced_start.m. Differences for the CyclonePlus:
% - The trigger is configured on the camera: TriggerMode On, TriggerSource Line1 (synchronizer cable at the camera I/O).
% - AcquisitionFrameRate is read-only while TriggerMode is On. The frame rate is set and checked with TriggerMode Off.
% - GenICam names: OptrImageStamp, Gain (dB), OptrEnableFan.
% - The frame rate is stored in UserData (needed in PIVlab_capture_OPTRONIS_plus_bitflow_save).
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
OutputError=0;

%% Prepare camera
delete(imaqfind); %clears all previous videoinputs
imaqreset
try
    hwinf = imaqhwinfo;
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
%% select bitmode
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end
if bitmode==8
    camfilemode='PIVMode8bit';
else
    camfilemode='PIVMode10bit';
end
%% camera model specific settings
camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, 'CyclonePlus-25')
    bfml_name = 'Optronis-CyclonePlus-25-M_OLT.bfml'; %like the Cyclone-25-150-M bfml, but without AcquisitionFrameRate (read-only while TriggerMode is On)
    exposure_gap=24; %time between end of exposure and next trigger (us)
    max_expo=50000; %max. exposure time in trigger mode (us)
    min_expo=8; %min. exposure time (us)
else
    disp('bfml file does not exist for this camera type')
    OutputError=1;
    OPTRONIS_vid=[];
    frame_nr_display=[];
    return
end

bfml_dir  = fileparts(mfilename('fullpath'));
bfml_path = fullfile(bfml_dir, [camfilemode '@' bfml_name]);

if isinf(nr_of_images) %PIV preview
    buffers_needed = 125;
else
    buffers_needed = nr_of_images*2 / 4 ; % one quarter of images RAM buffer
end

OPTRONIS_vid = videoinput('bitflow', 1, [bfml_path ';BuffersToUse=' num2str(buffers_needed)]);
OPTRONIS_vid.UserData=struct('frame_rate',frame_rate); %needed in PIVlab_capture_OPTRONIS_plus_bitflow_save (AcquisitionFrameRate can not be read in trigger mode)
OPTRONIS_src = OPTRONIS_vid.Source;

%% camera idle and free running: makes AcquisitionFrameRate and AcquisitionMode writable
bf_set(OPTRONIS_src, 'AcquisitionStop', '1');
pause(0.01)
bf_set(OPTRONIS_src, 'TriggerSelector', 'ExposureStart'); %TriggerMode applies to the selected trigger
bf_set(OPTRONIS_src, 'TriggerMode', 'Off');

%% Counter and gain settings
OPTRONIS_gain = gui.retr('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end

OPTRONIS_counter = gui.retr('OPTRONIS_counter');
if isempty(OPTRONIS_counter)
    OPTRONIS_counter=1;
end

if OPTRONIS_counter==0
    bf_set(OPTRONIS_src, 'OptrImageStamp', 'Off');
elseif OPTRONIS_counter==1
    bf_set(OPTRONIS_src, 'OptrImageStamp', 'On');
end

bf_set(OPTRONIS_src, 'Gain', num2str(20*log10(OPTRONIS_gain))); %gain in dB, GUI gain is a factor (1, 2, 4)

%% Set ROI
ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
bf_set(OPTRONIS_src, 'OffsetX', '0'); % zero offsets before changing size to avoid constraint violations
bf_set(OPTRONIS_src, 'OffsetY', '0');
bf_set(OPTRONIS_src, 'Width',   num2str(ROI_OPTRONIS(3)));
bf_set(OPTRONIS_src, 'Height',  num2str(ROI_OPTRONIS(4)));
bf_set(OPTRONIS_src, 'OffsetX', num2str(ROI_OPTRONIS(1)));
bf_set(OPTRONIS_src, 'OffsetY', num2str(ROI_OPTRONIS(2)));
% VideoResolution stays at the BFML default (sensor size); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
OPTRONIS_climits=2^bitmode;

image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 OPTRONIS_climits]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);
frame_nr_display=text(PIVlab_axis,100,100,'Initializing...','Color',[1 1 0]);

colormap(ancestor(PIVlab_axis,'figure'),'default')
new_map=colormap(ancestor(PIVlab_axis,'figure'),'gray');
colormap(ancestor(PIVlab_axis,'figure'),new_map);axis(PIVlab_axis,'image');
set(PIVlab_axis,'ytick',[])
set(PIVlab_axis,'xtick',[])

%% Exposure time
exposure_time=ceil(1/frame_rate*1000^2-exposure_gap);
exposure_time=min(max(exposure_time,min_expo),max_expo);

%% Set frame rate (check if too high). Only possible with TriggerMode Off.
fps_too_high=0;
try
    bf_set(OPTRONIS_src, 'AcquisitionFrameRate', num2str(round(frame_rate)));
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionFrameRate';
    set_frame_rate = str2double(OPTRONIS_src.BFGTLNodeValueStr);
    if round(set_frame_rate) ~= round(frame_rate)
        fps_too_high=1;
        disp(['Frame rate not accepted by the camera: requested ' num2str(round(frame_rate)) ', camera reports ' num2str(set_frame_rate)])
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Frame rate too high','The frame rate is too high for the current configuration, please reduce it.', 'modal');
    end
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Frame rate too high','The frame rate is too high for the current configuration, please reduce it.', 'modal');
    fps_too_high=1;
end

if fps_too_high==0
    bf_set(OPTRONIS_src, 'ExposureTime', num2str(exposure_time)); %valid in free run too: exposure = 1/fps - gap

    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame+2;
    OPTRONIS_vid.FramesPerTrigger = OPTRONIS_frames_to_capture;

    if ~isinf(nr_of_images) %PIV capture
        disp('prewarm start')
        % Pre-warm: 2 frames with the camera free running (TriggerMode Off), discard
        % Ensures the CXP/DMA pipeline and camera state machine are fully initialised
        % before the real triggered acquisition, preventing the first-frame skip.
        bf_set(OPTRONIS_src, 'AcquisitionStop', '1'); % put camera in Idle (makes AcquisitionMode writable)
        pause(0.01)
        bf_set(OPTRONIS_src, 'AcquisitionMode', 'Continuous');
        OPTRONIS_vid.FramesPerTrigger  = 2;
        triggerconfig(OPTRONIS_vid, 'immediate');
        start(OPTRONIS_vid);
        wait(OPTRONIS_vid, 5);             % 2 frames; 5 s is a safe ceiling
        stop(OPTRONIS_vid);                % sends AcquisitionStop -> camera back to Idle
        flushdata(OPTRONIS_vid);           % discard warm-up frames
        pause(0.01)
        % AcquisitionMode stays Continuous: the CyclonePlus makes one exposure per Line1 trigger in Continuous mode
        % (the old Cyclone needed SingleFrame)
        OPTRONIS_vid.FramesPerTrigger  = OPTRONIS_frames_to_capture;
        pause(0.1);
        disp('prewarm stop')
    end

    %% one exposure per rising edge of the synchronizer signal on Line1 (camera I/O)
    bf_set(OPTRONIS_src, 'AcquisitionStop', '1'); %TriggerMode can only be changed while the camera is idle
    pause(0.01)
    bf_set(OPTRONIS_src, 'AcquisitionMode',   'Continuous'); %also in PIV preview (no pre-warm there)
    bf_set(OPTRONIS_src, 'TriggerSelector',   'ExposureStart');
    bf_set(OPTRONIS_src, 'TriggerMode',       'On');
    bf_set(OPTRONIS_src, 'TriggerSource',     'Line1');
    bf_set(OPTRONIS_src, 'TriggerActivation', 'RisingEdge');
    bf_set(OPTRONIS_src, 'ExposureMode',      'Timed');
    bf_set(OPTRONIS_src, 'ExposureTime',      num2str(exposure_time));
    if ~isinf(nr_of_images)
        bf_set(OPTRONIS_src, 'OptrEnableFan', 'Off');
    end

    OPTRONIS_vid.ErrorFcn = @CustomIMAQErrorFcn;
    %No preview(): synced_capture shows downsampled frames via peekdata (displaying the full frames at a
    %high rate causes skipped frames and a high CPU load). In PIV preview (nr_of_images = Inf,
    %FramesPerTrigger = Inf), synced_capture discards the frames continuously.

    tmp=get(image_handle_OPTRONIS,'CData');
    tmp=size(tmp(:,:,1));
    set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);
    pause(0.01)
    caxis([0 2^bitmode]);

    %%% manual trigger: logging starts when trigger(OPTRONIS_vid) is called
    triggerconfig(OPTRONIS_vid, 'manual');
    start(OPTRONIS_vid);
    pause(0.1)
    trigger(OPTRONIS_vid) %also in PIV preview: frames must be logged for peekdata
    pause(0.1)
    drawnow;
    %Here: capture is running, waiting for the synchronizer signal on Line1.
else
    setappdata(hgui,'cancel_capture',1) %nothing will be captured
end

function bf_set(src, name, value)
%writes a camera node and reports (with the node name) if the value was not accepted
lastwarn('');
try
    src.BFGTLNodeName     = name;
    src.BFGTLNodeValueStr = value;
catch ME
    fprintf('*** BFGTLNode error: %-22s = %-14s  %s\n', name, value, ME.message);
    return
end
[w, wid] = lastwarn;
if ~isempty(w)
    fprintf('*** BFGTLNode warning: %-22s = %-14s  [%s]\n', name, value, wid);
end
if ~any(strcmp(name, {'AcquisitionStop','AcquisitionStart'})) %command nodes can not be read back
    try
        readback = src.BFGTLNodeValueStr;
    catch
        readback = '(not readable)';
    end
    if ~strcmpi(strtrim(readback), value) && ~(~isnan(str2double(value)) && abs(str2double(readback)-str2double(value)) < 0.5)
        fprintf('*** BFGTLNode not accepted: %-22s wrote %-14s reads %s\n', name, value, readback);
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
    EventType, char(datetime(EventDataTime,'Format','HH:mm:ss')), name);

if strcmpi(EventType, 'error')
    fprintf('%s\n', EventData.Message);
end

if strcmpi(event.Data.MessageID,'imaq:imaqmex:outofmemory')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Memory full','Out of memory. RAM is full, most likely, you need to lower the amount of frames to capture to fix this error.','modal');
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Image capture timeout. Most likely, memory is full and you need to lower the amount of frames to capture to fix this error. It is also possible that the synchronization cable is not plugged in correctly.','modal');
end
