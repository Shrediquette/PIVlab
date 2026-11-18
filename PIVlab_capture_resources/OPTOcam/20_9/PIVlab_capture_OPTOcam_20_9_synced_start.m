function [OutputError,OPTOcam_vid,frame_nr_display,max_pair_rate] = PIVlab_capture_OPTOcam_20_9_synced_start(nr_of_images,ROI_OPTOcam,frame_rate,bitmode,exposure1,n_cameras)
% Prepare one OPTOcam 20/9, or two for stereo acquisition (n_cameras = 2, both on the same trigger), for
% synced double-frame PIV capture using the sensor's native double-frame (mvPivShutter) mode. ONE external
% trigger on Line4 makes the sensor expose frame A (short, = exposure1) then frame B (long, automatic), i.e.
% one trigger -> one image pair (double_shutter principle, like the pco cameras). The synchronizer therefore
% sends nr_of_images trigger pulses and each camera delivers nr_of_images*2 frames (A,B,A,B,...), saved later
% as _A/_B pairs.
% OPTOcam_vid: cell array with one videoinput per camera ({1} = camera 1).
%
% frame_rate here is the image-PAIR rate (pairs/s), consistent with the fps popup.
% max_pair_rate is the highest achievable pair rate for the current ROI / bit depth (pairs/s; stereo: of the
% slower camera), read from the camera BEFORE the double-frame mode is enabled (see configure_synced); the
% caller must use this value and not query mvResultingFrameRate itself.
if nargin < 6
	n_cameras = 1;
end
hgui=getappdata(0,'hgui');
OutputError=0;
max_pair_rate=inf;
frame_nr_display=[];

binning = getappdata(hgui,'binning'); %set with the "Binning" button
if isempty(binning)
    binning = 1;
end
if nargin < 5 || isempty(exposure1)
    exposure1 = 60; %us, lands in the minimum (123.5 us) frame-1 exposure plateau
end
exposure1 = max(7, min(2522, exposure1)); %settable ExposureTime range (measured on the rig)

%% Prepare cameras (opened in the requested bit depth, or reused if already open)
[OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_20_9_open(bitmode,n_cameras);
if imaq_error~=0
    OutputError=1; OPTOcam_vid={};
    return
end
ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %0-based offset for the camera
for k=1:n_cameras
	max_pair_rate = min(max_pair_rate,configure_synced(OPTOcam_vid{k},ROI_OPTOcam,binning,exposure1));
end
if ~isinf(max_pair_rate)
	disp(['Maximum image-pair rate with current settings: ' num2str(round(max_pair_rate,1)) ' pairs/s.'])
end
disp(['Requested image-pair rate: ' num2str(frame_rate) ' pairs/s.']);

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
[image_handles,frame_nr_display] = acquisition.live_images(n_cameras,[ROI_OPTOcam(3) ROI_OPTOcam(4)],2^bitmode);
setappdata(hgui,'image_handles_OPTOcam_20_9',image_handles);

%% start acquisition (waiting for external triggers)
OPTOcam_frames_to_capture = nr_of_images*2; %2 frames (A,B) per pair
for k=1:n_cameras
	OPTOcam_vid{k}.FramesPerTrigger = OPTOcam_frames_to_capture;
	if ~isinf(nr_of_images) %only start capturing if save box is ticked.
		flushdata(OPTOcam_vid{k});
		OPTOcam_vid{k}.ErrorFcn = @CustomIMAQErrorFcn;
		start(OPTOcam_vid{k});
	end
end

%Frames arrive as A,B,A,B... and frame B (long fixed exposure) is much brighter with ambient
%light, so a plain preview would flicker. The callback shows frame A only (B via the A/B toggle),
%see PIVlab_capture_OPTOcam_20_9_preview_update.m
for k=1:n_cameras
	setappdata(image_handles{k},'OPTOcam_20_9_ab_state',[]);
	setappdata(image_handles{k},'max_display_rate',1); %until the first update of synced_capture (acquisition.display_rate)
	setappdata(image_handles{k},'UpdatePreviewWindowFcn',@PIVlab_capture_OPTOcam_20_9_preview_update);
	preview(OPTOcam_vid{k},image_handles{k});
end
caxis(PIVlab_axis,[0 2^bitmode]); %#ok<CAXIS> workaround to force preview to show full data range
acquisition.apply_camera_view %preview() sets the axes limits to its own image: show the cameras chosen with the CAM button
pause(0.1);
if ~isinf(nr_of_images)
	for k=1:n_cameras
		status=[];
		while isempty(status) %make sure OPTOcam is ready...
			status=OPTOcam_vid{k}.Eventlog;
			pause(0.001)
		end
	end
end
drawnow;
pause(0.05)

function max_pair_rate = configure_synced(OPTOcam_vid,ROI_OPTOcam,binning,exposure1)
%triggered double-frame camera for the PIV capture (stereo: the same settings for both cameras)
OPTOcam_settings = get(OPTOcam_vid);
%Use the full USB3 bandwidth (no artificial throughput limit). The measured max pair rate depends
%on ROI/bit depth; the settings check in piv_capture_Callback warns if the requested rate is not achievable.
try
    OPTOcam_settings.Source.DeviceLinkThroughputLimitMode = 'Off';
catch
end
OPTOcam_vid.PreviewFullBitDepth='On';

%% Binning. Must be set BEFORE the ROI: the ROI is in binned pixels.
OPTOcam_settings.Source.mvShutterMode = 'mvGlobalShutter'; %(a reused camera may still be in double-frame mode)
if OPTOcam_settings.Source.BinningHorizontal ~= binning || OPTOcam_settings.Source.BinningVertical ~= binning
    try
        OPTOcam_vid.ROIPosition = [0 0 OPTOcam_vid.VideoResolution]; %full frame first, so the (reused) camera accepts the new binning
    catch
    end
    OPTOcam_settings.Source.BinningHorizontalMode = 'Average'; %no changes to bitmode, max and min stays the same
    OPTOcam_settings.Source.BinningVerticalMode = 'Average';
    OPTOcam_settings.Source.BinningHorizontal = binning; %1, 2 or 4
    OPTOcam_settings.Source.BinningVertical = binning;
    %MATLAB updates VideoResolution only when an acquisition starts (measured). Without this, a larger
    %ROI is rejected after reducing the binning ("VideoResolution width exceeded").
    start(OPTOcam_vid); stop(OPTOcam_vid);
end

%% ROI
OPTOcam_vid.ROIPosition=ROI_OPTOcam;

%orientation: default (no mirroring). Flip here if the image is mirrored on the rig.
OPTOcam_settings.Source.ReverseX = 'False';
OPTOcam_settings.Source.ReverseY = 'False';

OPTOcam_gain = gui.camera_setting('OPTOcam_20_9_gain');
if isempty (OPTOcam_gain)
    OPTOcam_gain=0;
end
OPTOcam_settings.Source.Gain = OPTOcam_gain;

%% first-frame (A) exposure.
%The value is produced by the shared timing model (PIVlab_capture_OPTOcam_20_9_timing.m): it is
%chosen so that laser pulse 1 fits into frame 1 AND so that the camera's exposure quantisation
%stays predictable (the setting sits in the middle of a quantisation plateau).
OPTOcam_settings.Source.mvShutterMode = 'mvGlobalShutter'; %single-frame mode for the frame-rate query below
OPTOcam_settings.Source.ExposureMode  = 'Timed';
OPTOcam_settings.Source.TriggerMode   = 'Off';
OPTOcam_settings.Source.ExposureTime  = exposure1;
try %the live image limits the camera to 10 frames/s
    OPTOcam_settings.Source.AcquisitionFrameRateEnable = 'False';
catch
end

%% maximum achievable pair rate for the current ROI / bit depth
%mvResultingFrameRate is only re-evaluated by the camera in single-frame (mvGlobalShutter) mode.
%Once mvPivShutter is active the node FREEZES at its last value (measured: exposure changes are
%ignored, so it would still report the rate of the long live-image exposure). It is therefore
%read here, with ROI/bit depth/exposure already applied but BEFORE the double-frame mode is
%switched on. The value is the readout-limited single-frame rate; in double-frame mode the camera
%delivers exactly that many single frames per second (measured), i.e. half as many image pairs.
try
    max_pair_rate = get(OPTOcam_vid.Source,'mvResultingFrameRate')/2; %2 frames per image pair
catch
    max_pair_rate = inf;
end

%% double-frame (mvPivShutter) + hardware trigger on Line4
triggerconfig(OPTOcam_vid, 'hardware');
OPTOcam_settings.Source.mvShutterMode  = 'mvPivShutter'; %sensor-native double frame (one trigger -> pair)
OPTOcam_settings.Source.TriggerSelector= 'FrameStart';
OPTOcam_settings.Source.TriggerSource  = 'Line4';       %external trigger input from the synchronizer
OPTOcam_settings.Source.TriggerActivation = 'RisingEdge';
OPTOcam_settings.Source.TriggerMode    = 'On';
OPTOcam_settings.Source.ExposureTime   = exposure1;     %re-apply: the mode switch clamps ExposureTime to its double-frame range
%Camera firmware: the double-frame mode adapts to a new image size only when the ROI is CHANGED while
%mvPivShutter is active. With the ROI set in mvGlobalShutter only (above), a double-frame acquisition
%with a larger area than before delivers mixed-up, tiled frames. Writing the same ROI again is
%ignored, so first a ROI 16 rows smaller (or larger), then the real one.
if ROI_OPTOcam(4) >= 32
    OPTOcam_vid.ROIPosition = [ROI_OPTOcam(1) ROI_OPTOcam(2) ROI_OPTOcam(3) ROI_OPTOcam(4)-16];
else
    OPTOcam_vid.ROIPosition = [ROI_OPTOcam(1) ROI_OPTOcam(2) ROI_OPTOcam(3) ROI_OPTOcam(4)+16];
end
OPTOcam_vid.ROIPosition = ROI_OPTOcam;

%% Line0 = ExposureActive output (used to measure timings/delays on the rig)
OPTOcam_settings.Source.LineSelector = 'Line0';
OPTOcam_settings.Source.LineSource   = 'ExposureActive';
OPTOcam_settings.Source.LineInverter = 'False';

%% Line1 = AcquisitionActive output (used to signal activity on the camera LED and to turn off the fan)
OPTOcam_settings.Source.LineSelector = 'Line1';
OPTOcam_settings.Source.LineSource   = 'AcquisitionActive';
OPTOcam_settings.Source.LineInverter = 'False';

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
