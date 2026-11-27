function [OPTRONIS_vids,imaq_error] = PIVlab_capture_OPTRONIS_bitflow_open(camfilemode,n_cameras,buffers)
%PIVlab_capture_OPTRONIS_bitflow_open  Open one OPTRONIS Cyclone on the BitFlow grabber, or two for stereo acquisition.
%
%   [OPTRONIS_vids,imaq_error] = PIVlab_capture_OPTRONIS_bitflow_open(camfilemode,n_cameras,buffers)
%
%   camfilemode    mode in the bfml file: 'PIVMode8bit', 'PIVMode10bit' or 'CalibrationMode10bit'
%   n_cameras      1, or 2 for stereo acquisition (two Cyclone-2-2000-M on one grabber)
%   buffers        BuffersToUse of the grabber (per camera)
%   OPTRONIS_vids  cell array with one videoinput per camera; {1} is camera 1
%   imaq_error     0 = ok, 1 = no Image Acquisition Toolbox, 2 = no BitFlow adaptor, 3 = camera not found,
%                  4 = stereo: the second camera was not found
%
%   The grabber has four CoaXPress links. One camera uses all four (grabber device 1). Two cameras use two
%   links each: camera lanes 1-2 to grabber links 1-2 (device 1) and to links 3-4 (device 3). The grabber
%   opens a device with the first camera file of that device in BitFlow SysReg: for two cameras this must be
%   the 2-link file (Optronis-Cyclone-2-2000-M-2links_OLT.bfml) for VFG0 and VFG2. A videoinput with the
%   4-link file then still uses four links when one camera is connected with four cables.
%   One Cyclone-2-2000-M: the 4-link file, or the 2-link file when only two links are connected.
%   Camera 1 and 2 of a stereo setup: device 1 and 3, exchanged with "Swap cameras" in the camera settings
%   (camera setting 'OPTRONIS_stereo_swap').
if nargin < 2
	n_cameras = 1;
end
if nargin < 3
	buffers = 4;
end
OPTRONIS_vids = {};
imaq_error = 0;
try
	delete(imaqfind); %clears all previous videoinputs
	warning off
	hwinf = imaqhwinfo;
catch
	imaq_error = 1;
end
if imaq_error == 0 && ~any(strcmp(hwinf.InstalledAdaptors,'bitflow'))
	imaq_error = 2;
end

%% camera files: the first one that opens is used
camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, '25-150')
	bfml_names = {'Optronis-Cyclone-25-150-M_OLT.bfml'};
elseif contains(camera_sub_type, '2-2000')
	if n_cameras == 1
		bfml_names = {'Optronis-Cyclone-2-2000-M_OLT.bfml','Optronis-Cyclone-2-2000-M-2links_OLT.bfml'};
	else
		bfml_names = {'Optronis-Cyclone-2-2000-M-2links_OLT.bfml'};
	end
elseif contains(camera_sub_type, '1HS-3500')
	bfml_names = {'Optronis-Cyclone-1HS-3500-M_OLT.bfml'}; %does not exist yet
else
	bfml_names = {};
	if imaq_error == 0
		imaq_error = 3;
	end
end

%% grabber devices
if n_cameras == 1
	devices = 1;
else
	devices = [1 3];
	if isequal(gui.camera_setting('OPTRONIS_stereo_swap'),1)
		devices = [3 1];
	end
end

bfml_dir = fileparts(mfilename('fullpath'));
if imaq_error == 0
	OPTRONIS_vids = cell(1,n_cameras);
	for k = 1:n_cameras
		for f = 1:numel(bfml_names)
			try
				OPTRONIS_vids{k} = videoinput('bitflow', devices(k), [fullfile(bfml_dir,[camfilemode '@' bfml_names{f}]) ';BuffersToUse=' num2str(buffers)]);
				break
			catch
				OPTRONIS_vids{k} = [];
			end
		end
		if isempty(OPTRONIS_vids{k})
			if k == 1
				imaq_error = 3;
			else
				imaq_error = 4;
			end
			break
		end
		OPTRONIS_vids{k}.Tag = sprintf('OPTRONIS_cam%d',k);
		OPTRONIS_src = OPTRONIS_vids{k}.Source;
		try
			OPTRONIS_src.BFGTLNodeName = 'DeviceSerialNumber';
			serial = OPTRONIS_src.BFGTLNodeValueStr;
			OPTRONIS_src.BFGTLNodeName = 'CxpLinkConfiguration';
			links = OPTRONIS_src.BFGTLNodeValueStr;
		catch
			serial = '?';
			links = '?';
		end
		disp(['Found camera ' int2str(k) ': ' camera_sub_type ' on BitFlow device ' int2str(devices(k)) ', serial number ' serial ', ' links])
	end
end

if imaq_error == 1
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
	disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
elseif imaq_error == 2
	disp('ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB adaptor.')
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, adaptor missing','ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB IMAQ adaptor.','modal');
elseif imaq_error == 3
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected and switched on?','modal');
elseif imaq_error == 4
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Stereo acquisition', ...
		{'The second camera was not found.' ...
		'Two cameras on one BitFlow grabber: camera 1 (lanes 1 and 2) on grabber links 1 and 2, camera 2 on grabber links 3 and 4.' ...
		'In BitFlow SysReg, the camera file of VFG0 and VFG2 must be Optronis-Cyclone-2-2000-M-2links_OLT.bfml.'},'modal');
end
if imaq_error ~= 0
	for k = 1:numel(OPTRONIS_vids)
		if ~isempty(OPTRONIS_vids{k})
			delete(OPTRONIS_vids{k});
		end
	end
	OPTRONIS_vids = {};
end
end
