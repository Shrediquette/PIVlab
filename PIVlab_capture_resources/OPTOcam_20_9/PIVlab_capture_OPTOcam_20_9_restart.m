function PIVlab_capture_OPTOcam_20_9_restart(resume_msg)
%PIVlab_capture_OPTOcam_20_9_restart  Restart the OPTOcam 20/9 when the image area has become larger.
%
%   PIVlab_capture_OPTOcam_20_9_restart(resume_msg)
%
%   Camera firmware workaround (measured 2026-11-11): after an acquisition in double-frame mode, every
%   later double-frame acquisition with a larger sensor area (ROI x binning^2) delivers mixed-up frames
%   (tiled image, frames A and B equally bright) or no frames at all. Only a restart of the camera
%   clears this. PIVlab_capture_OPTOcam_20_9_synced_start keeps the smallest sensor area used in
%   double-frame mode since the last restart in the root appdata 'OPTOcam_20_9_min_piv_area' (the
%   camera state outlives a PIVlab restart). This function compares it with the current ROI / binning
%   of the GUI and restarts the camera (about 20 s) when the area is larger.
%
%   resume_msg   '' when called after the ROI selection or a binning change: the controls are locked
%                while the camera restarts. Called by synced_start (fallback) with the status text of
%                the capture that has locked the controls already: only the status strip changes.

min_piv_area = getappdata(0,'OPTOcam_20_9_min_piv_area');
if isempty(min_piv_area)
	return
end
binning = gui.retr('binning');
if isempty(binning)
	binning = 1;
end
roi = gui.retr('ac_ROI_general');
if isempty(roi)
	max_cam_res = gui.retr('max_cam_res');
	roi = [1 1 max_cam_res(1)/binning max_cam_res(2)/binning];
end
if roi(3)*roi(4)*binning^2 <= min_piv_area
	return
end

busy_msg = 'Restarting the camera for the larger image area (about 30 s)...';
if isempty(resume_msg)
	gui.toolsavailable(0,busy_msg);
else
	gui.busy_hint(busy_msg);
end
drawnow;
disp(busy_msg)
bitmode = gui.camera_setting('OPTOcam_20_9_bits');
if isempty(bitmode)
	bitmode = 8;
end
[OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_20_9_open(bitmode); %reports a missing camera itself
restart_failed = false;
if imaq_error == 0
	try
		executeCommand(getselectedsource(OPTOcam_vid),'DeviceReset');
	catch
		restart_failed = true;
	end
	if ~restart_failed
		delete(imaqfind);
		%The camera needs 13-17 s to restart (measured). A device search during that time still finds it
		%(it has not disconnected yet), and opening it then can block MATLAB. Therefore a fixed wait, in
		%which PIVlab stays responsive (the status strip shows the elapsed time).
		t0 = tic;
		while toc(t0) < 20
			pause(0.2)
		end
		gui.busy_hint('Connecting to the camera...');
		drawnow;
		imaqreset;
		setappdata(0,'OPTOcam_20_9_min_piv_area',[]);
		PIVlab_capture_OPTOcam_20_9_open(bitmode); %device search + open, about 8 s; reused by the next capture
	end
end
if isempty(resume_msg)
	gui.toolsavailable(1);
else
	gui.busy_hint(resume_msg);
end
if restart_failed
	gui.custom_msgbox('error',getappdata(0,'hgui'),'Camera restart failed', ...
		'The camera could not be restarted by software. Please unplug the camera for a few seconds before the next PIV capture.','modal');
end
end
