function [OutputError,OPTRONIS_vid,frame_nr_display] = PIVlab_capture_OPTRONIS_bitflow_synced_start(nr_of_images,ROI_OPTRONIS,frame_rate,bitmode)
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
    camfilemode='PIVMode8bit'; % funktioniert ohne Fehlermeldung, timing + dropped frames nicht kontrolliert.
else
    camfilemode='PIVMode10bit';
end
%% select cam subtype
camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, '25-150')
    bfml_name = 'Optronis-Cyclone-25-150-M_OLT.bfml'; %does not exist yet
    exposure_gap = 24;
    minexpo = 12;
elseif contains(camera_sub_type, '2-2000')
    bfml_name = 'Optronis-Cyclone-2-2000-M_OLT.bfml';
    exposure_gap = 3;
    minexpo = 2;
elseif contains(camera_sub_type, '1HS-3500')
    bfml_name = 'Optronis-Cyclone-1HS-3500-M_OLT.bfml'; %does not exist yet
    exposure_gap = 3;
    minexpo = 2;
else
    disp('bfml file does not exist for this camera type')
    return
end
if bitmode > 8
    exposure_gap = exposure_gap + 1; %maximum exposure issmaller at 10 bit
end

bfml_dir  = fileparts(mfilename('fullpath'));
bfml_path = fullfile(bfml_dir, [camfilemode '@' bfml_name]);

if isinf(nr_of_images) %PIV preview
    buffers_needed = 125;
else
    buffers_needed = nr_of_images*2 / 4 ; % one quarter of images RAM buffer
end

OPTRONIS_vid = videoinput('bitflow', 1, [bfml_path ';BuffersToUse=' num2str(buffers_needed)]);
OPTRONIS_src = OPTRONIS_vid.Source;

%% Set exposure time
exposure_time = ceil(1/frame_rate*1000^2 - exposure_gap);
OPTRONIS_src.BFGTLNodeName = 'ExposureTime';
OPTRONIS_src.BFGTLNodeValueStr = num2str(round(exposure_time));

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
    OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
    OPTRONIS_src.BFGTLNodeValueStr = 'Off';
elseif OPTRONIS_counter==1
    OPTRONIS_src.BFGTLNodeName     = 'CounterInformation';
    OPTRONIS_src.BFGTLNodeValueStr = 'On';
end

OPTRONIS_src.BFGTLNodeName     = 'AGain';
OPTRONIS_src.BFGTLNodeValueStr = num2str(OPTRONIS_gain);


%% Set ROI
ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
%'ist das so?'
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
% VideoResolution stays at the BFML default (1920×1080); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
OPTRONIS_climits=2^bitmode;

image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 OPTRONIS_climits]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);

colormap default
new_map=colormap('gray');
colormap(new_map);axis image;
set(gui.retr('pivlab_axis'),'ytick',[])
set(gui.retr('pivlab_axis'),'xtick',[])


%% Set frame rate (check if too high)
fps_too_high=0;
try
    OPTRONIS_src.BFGTLNodeName     = 'AcquisitionFrameRate';
    OPTRONIS_src.BFGTLNodeValueStr = num2str(round(frame_rate));
    set_frame_rate = str2num(OPTRONIS_src.BFGTLNodeValueStr);
    if set_frame_rate ~= round(frame_rate)
        fps_too_high=1;
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Frame rate too high','The frame rate is too high for the current configuration, please reduce it.', 'modal');
    end
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Frame rate too high','The frame rate is too high for the current configuration, please reduce it.', 'modal');
    fps_too_high=1;
end


if fps_too_high==0
    OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
    OPTRONIS_src.BFGTLNodeValueStr = 'Off';

    OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame+2;
    OPTRONIS_vid.FramesPerTrigger = OPTRONIS_frames_to_capture;
    %OPTRONIS_vid.TriggerRepeat = 0;

    if ~isinf(nr_of_images) %PIV capture
        disp('prewarm start')
        % Pre-warm: 2 frames with internal trigger (Continuous mode), discard
        % Ensures the CXP/DMA pipeline and camera state machine are fully initialised
        % before the real triggered acquisition, preventing the first-frame skip.
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
    end
    OPTRONIS_vid.ErrorFcn = @CustomIMAQErrorFcn;
    if bitmode > 8
        set(OPTRONIS_vid, 'PreviewFullBitDepth', 'on');
    end

    %% Start PREVIEW
    preview(OPTRONIS_vid, image_handle_OPTRONIS);


    tmp=get(image_handle_OPTRONIS,'CData');
    tmp=size(tmp(:,:,1));
    set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
    delete(frame_nr_display);
    frame_nr_display=text(100,100,'Ready!','Color',[1 1 0]);

    %% Verify active settings read back from camera
    %{
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionFrameRate';
    disp(['  AcquisitionFrameRate (active) = ' OPTRONIS_src.BFGTLNodeValueStr ' fps']);
    OPTRONIS_src.BFGTLNodeName = 'ExposureTime';
    disp(['  ExposureTime         (active) = ' OPTRONIS_src.BFGTLNodeValueStr ' µs']);
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionMode';
    disp(['  AcquisitionMode      (active) = ' OPTRONIS_src.BFGTLNodeValueStr]);
    OPTRONIS_src.BFGTLNodeName = 'SyncInActivation';
    disp(['  SyncInActivation     (active) = ' OPTRONIS_src.BFGTLNodeValueStr]);
    %}
    pause(0.01)
    caxis([0 2^bitmode]);


    %%% Variante mit manuellem trigger
    triggerconfig(OPTRONIS_vid, 'manual'); %so recording starts only when (trigger(OPTR... is called
    start(OPTRONIS_vid);
    pause(0.1)
    if ~isinf(nr_of_images)
        %flushdata(OPTRONIS_vid)
        pause(0.1)
        trigger(OPTRONIS_vid)
        pause(0.1)
        drawnow;
    end
    %Here: preview / capture is running, waiting for external trigger input.
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