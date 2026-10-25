function [OPTOcam_vids,imaq_error] = PIVlab_capture_OPTOcam_open(bitmode,n_cameras)
%PIVlab_capture_OPTOcam_open  Find and open one or two OPTOcam 2/80, or reuse the cameras that are already open.
%
%   [OPTOcam_vids,imaq_error] = PIVlab_capture_OPTOcam_open(bitmode,n_cameras)
%
%   bitmode       8 (Mono8) or 12 (Mono12)
%   n_cameras     1, or 2 for stereo acquisition
%   OPTOcam_vids  cell array with one videoinput per camera; {1} is camera 1
%   imaq_error    0 = ok, 1 = no Image Acquisition Toolbox, 2 = no GenTL adaptor, 3 = camera not found,
%                 4 = stereo: fewer than two cameras found
%
%   Camera 1 and 2 of a stereo setup are told apart by their serial numbers (camera setting
%   'OPTOcam_stereo_serials', set the first time and swapped in the OPTOcam settings window); by default
%   the camera with the lower serial number is camera 1. With one camera and two connected, camera 1 of the
%   stereo setup is used.
%   Opening a camera takes ~2 s, so the videoinput objects are kept after a capture (tags 'OPTOcam_cam1',
%   'OPTOcam_cam2') and reused while the pixel format matches. All camera settings are applied by the callers
%   every time. Changing the configuration in the GUI releases the cameras
%   (select_capture_config_Callback: delete(imaqfind) + imaqreset).

if bitmode == 8
	video_format = 'Mono8';
else
	video_format = 'Mono12';
end
warning('off','imaq:gentl:noSupportedPixelFormat')
OPTOcam_vids = cell(1,n_cameras);

%% fast path: reuse the opened cameras
try
	reuse_ok = true;
	for k = 1:n_cameras
		vid = imaqfind('Tag',sprintf('OPTOcam_cam%d',k));
		if iscell(vid) %imaqfind returns a cell array here
			vid = [vid{:}];
		end
		if isscalar(vid) && isvalid(vid) && strcmp(vid.VideoFormat,video_format)
			OPTOcam_vids{k} = vid;
		else
			reuse_ok = false;
		end
	end
	if reuse_ok
		for k = 1:n_cameras
			if isrunning(OPTOcam_vids{k})
				stop(OPTOcam_vids{k});
			end
			stoppreview(OPTOcam_vids{k});
			flushdata(OPTOcam_vids{k});
			OPTOcam_vids{k}.ErrorFcn = ''; %set again by synced_start
		end
		imaq_error = 0;
		disp(['Found camera(s): OPTOcam 2/80 (already open, ' int2str(n_cameras) ')'])
		return
	end
catch
	%camera unplugged, toolbox reset etc. -> open again below
end

%% slow path: find the cameras and open them
OPTOcam_vids = {};
imaq_error = 0;
try
	delete(imaqfind); %clears all previous videoinputs
	warning off
	hwinf = imaqhwinfo;
catch
	imaq_error = 1;
end
if imaq_error == 0 && isempty(hwinf.InstalledAdaptors)
	imaq_error = 2;
end
if imaq_error == 0
	imaq_error = 2;
	for adaptorID = 1:numel(hwinf.InstalledAdaptors)
		info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
		%'gentl' in a normal MATLAB, 'mwgentlimaq' when the adaptor was registered by path (imaqregister)
		if strcmp(info.AdaptorName,'gentl') || strcmp(info.AdaptorName,'mwgentlimaq')
			imaq_error = 0;
			break
		end
	end
end
candidates = [];
if imaq_error == 0
	for CamID = 1:size(info.DeviceInfo,2)
		camName = info.DeviceInfo(CamID).DeviceName;
		if contains(camName,'160um','IgnoreCase',true) || contains(camName,'OPTOcam','IgnoreCase',true)
			candidates(end+1) = CamID; %#ok<AGROW>
		end
	end
	if isempty(candidates)
		imaq_error = 3;
	elseif numel(candidates) < n_cameras
		imaq_error = 4;
	end
end

if imaq_error == 1
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
	disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
elseif imaq_error == 2
	disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
	disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, support package missing',{'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'modal');
elseif imaq_error == 3
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected?','modal');
elseif imaq_error == 4
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Stereo acquisition needs two OPTOcam 2/80, but only one was found. Are both cameras connected?','modal');
end
if imaq_error ~= 0
	return
end

%% open the cameras and read their serial numbers
saved_serials = gui.camera_setting('OPTOcam_stereo_serials');
if ~iscell(saved_serials)
	saved_serials = {};
end
opened = {};
serials = {};
for c = 1:numel(candidates)
	vid = videoinput(info.AdaptorName,info.DeviceInfo(candidates(c)).DeviceID,video_format);
	opened{end+1} = vid; %#ok<AGROW>
	serials{end+1} = serial_number(vid); %#ok<AGROW>
	if n_cameras == 1 && (isempty(saved_serials) || strcmp(serials{end},saved_serials{1}))
		break %the camera to use is open, the others are not needed
	end
end

%% camera 1 and 2
if n_cameras == 1
	use = numel(opened); %camera 1 of the stereo setup, or the first camera found
	if ~isempty(saved_serials) && ~strcmp(serials{use},saved_serials{1})
		use = 1;
	end
else
	use = [];
	if numel(saved_serials) == 2
		first = find(strcmp(serials,saved_serials{1}),1);
		second = find(strcmp(serials,saved_serials{2}),1);
		if ~isempty(first) && ~isempty(second)
			use = [first second];
		end
	end
	if isempty(use) %new cameras: camera 1 = the lower serial number
		[~,sorted] = sort(serials);
		use = sorted(1:2);
		gui.set_camera_setting('OPTOcam_stereo_serials',serials(use));
	end
end
for c = 1:numel(opened)
	if ~any(use == c)
		delete(opened{c});
	end
end
OPTOcam_vids = cell(1,n_cameras);
for k = 1:n_cameras
	OPTOcam_vids{k} = opened{use(k)};
	OPTOcam_vids{k}.Tag = sprintf('OPTOcam_cam%d',k);
	disp(['Found camera ' int2str(k) ': OPTOcam 2/80, serial number ' serials{use(k)}])
end
end

function serial = serial_number(vid)
try
	serial = char(vid.Source.DeviceSerialNumber);
catch
	serial = '';
end
end
