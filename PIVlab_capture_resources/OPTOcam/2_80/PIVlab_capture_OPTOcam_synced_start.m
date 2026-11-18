function [OutputError,OPTOcam_vid,frame_nr_display] = PIVlab_capture_OPTOcam_synced_start(nr_of_images,ROI_OPTOcam,frame_rate,bitmode,n_cameras)
%Prepares one OPTOcam 2/80, or two for stereo acquisition (n_cameras = 2, both on the same trigger), for the
%PIV capture and starts them (waiting for the hardware trigger on Line2).
%OPTOcam_vid: cell array with one videoinput per camera ({1} = camera 1).
%Recording and PIV preview (nr_of_images = Inf) both log the frames; synced_capture shows the latest frame with
%peekdata at a limited rate. No preview(): drawing every frame costs CPU time and can make the cameras skip
%frames (same approach as the OPTRONIS driver).
if nargin < 5
	n_cameras = 1;
end
hgui=getappdata(0,'hgui');
OutputError=0;
frame_nr_display=[];

%% Prepare cameras
[OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_open(bitmode,n_cameras);
if imaq_error ~= 0
	OutputError=1;
	return
end
ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %unfortunaletly different definitions of ROI in pco and OPTOcam.
for k=1:n_cameras
	configure_synced(OPTOcam_vid{k},frame_rate,bitmode,ROI_OPTOcam);
end

%% prepare axes
PIVlab_axis = gui.retr('pivlab_axis');
[image_handles,frame_nr_display] = acquisition.live_images(n_cameras,[ROI_OPTOcam(3) ROI_OPTOcam(4)],2^bitmode);
setappdata(hgui,'image_handles_OPTOcam',image_handles);

%% display timing information
max_fps_with_current_settings = 1/((get(OPTOcam_vid{1}.Source,'SensorReadoutTime') + get(OPTOcam_vid{1}.Source,'BslExposureStartDelay'))/1000/1000);
disp(['Maximum fps with current settings: ' num2str(max_fps_with_current_settings) ' fps.'])
disp(['Requested fps: ' num2str(frame_rate) ' fps.']);

%% start acquisition (waiting for trigger)
OPTOcam_frames_to_capture = nr_of_images*2; %Inf in PIV preview: synced_capture discards the frames continuously
for k=1:n_cameras
	OPTOcam_vid{k}.FramesPerTrigger = OPTOcam_frames_to_capture;
	flushdata(OPTOcam_vid{k});
	OPTOcam_vid{k}.ErrorFcn = @CustomIMAQErrorFcn;
	start(OPTOcam_vid{k});
end
caxis(PIVlab_axis,[0 2^bitmode]); %#ok<CAXIS>
pause(0.1); %make sure OPTOcam is ready...
for k=1:n_cameras
	status=[];
	while isempty(status) %make sure OPTOcam is ready...
		status=OPTOcam_vid{k}.Eventlog;
		pause(0.001)
	end
end
drawnow;
pause(0.05)

function configure_synced(OPTOcam_vid,frame_rate,bitmode,ROI_OPTOcam)
%triggered camera for the PIV capture (stereo: the same settings for both cameras)
OPTOcam_src = OPTOcam_vid.Source;
try
	executeCommand(OPTOcam_src,"BslSensorOn")
	disp('Waking up sensor from sleep mode.')
catch %not available with the 'mwgentlimaq' adaptor
end
pause(0.1)

%% setting USB speed to be slightly higher than required
OPTOcam_src.DeviceLinkThroughputLimitMode = 'on';
bitmultiply = bitmode*0.25 -1;
ThroughputLimit=round(2500000 * frame_rate * bitmultiply * 1.025); % required USB bandwidth at 8 bit.
if ThroughputLimit > 2500000 * 160 *1.025
	ThroughputLimit = round(2500000 * 160*1.025);
elseif ThroughputLimit < 2500000 * 16
	ThroughputLimit = 2500000 * 16;
end
OPTOcam_src.DeviceLinkThroughputLimit=ThroughputLimit;
disp(['DeviceLinkThroughputLimitMode set to: ' num2str(ThroughputLimit) '.'])
pause(0.1)
OPTOcam_vid.PreviewFullBitDepth='On';

%% set camera parameters for triggered acquisition
triggerconfig(OPTOcam_vid, 'hardware');
OPTOcam_src.ExposureMode = 'Timed';
OPTOcam_src.TriggerSource ='Line2';
OPTOcam_src.TriggerSelector='FrameStart';
OPTOcam_src.TriggerMode ='On';
try %the live image limits the frame rate (camera objects are reused): the trigger sets the rate here
	OPTOcam_src.AcquisitionFrameRateEnable = 'False';
catch
end

%% set line4 to output exposureactive signal (stereo: both cameras, their outputs are not connected)
OPTOcam_src.LineSelector='Line4';
OPTOcam_src.LineSource = 'ExposureActive';
OPTOcam_src.LineMode = 'Output';

if bitmode==8
    exposure_time= floor(1/frame_rate*1000*1000-44);
elseif bitmode==12
    exposure_time= floor(1/frame_rate*1000*1000-96);
end
OPTOcam_src.ExposureTime =exposure_time;
OPTOcam_src.LineInverter='False';
OPTOcam_vid.ROIPosition=ROI_OPTOcam;
OPTOcam_src.ReverseX = 'True';
OPTOcam_src.ReverseY = 'True';
OPTOcam_gain = gui.camera_setting('OPTOcam_gain');
if isempty (OPTOcam_gain)
    OPTOcam_gain=0;
end
OPTOcam_src.Gain = OPTOcam_gain;

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
