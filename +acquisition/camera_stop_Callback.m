function camera_stop_Callback(~,evt,~)
was_capturing=gui.retr('capturing');
gui.put('cancel_capture',1);
if ~strcmpi(gui.retr('camera_type'),'webcam')
	acquisition.control_simple_sync_serial(0,0);
end
%external_device_control(0);
gui.put('laser_running',0);
gui.put('capturing',0);
%unlock only when a capture locked the controls: without a capture, gui.toolsavailable(1) would
%grey out again the controls that were off at the start of the last capture (e.g. "Image amount"
%after "Save" was ticked)
if ~isempty(was_capturing) && was_capturing == 1
	gui.toolsavailable(1)
end
fresh_calib_image=gui.retr('fresh_calib_image');
if strncmp(evt.Source.Tag,'ac_calibsave',20) %only when "save" button is pressed, then save the calibration image.
	if ~isempty(fresh_calib_image) && fresh_calib_image == 1
		gui.put('fresh_calib_image',0);
		handles=gui.gethand;
		projectpath=get(handles.ac_project,'String');
		caliimg=gui.retr('caliimg');
		if iscell(caliimg) %stereo acquisition: one image per camera, in cam1 and cam2 with the same number
			folders=acquisition.capture_folders(projectpath,numel(caliimg));
		else
			folders={projectpath};
			caliimg={caliimg};
		end
		numbi = 0;
		while calibration_image_exists(folders,numbi)
			numbi = numbi+1;
		end
		for k=1:numel(folders)
			if ~exist(folders{k},'dir')
				mkdir(folders{k});
			end
			imwrite(caliimg{k},fullfile(folders{k}, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']));
		end
		set(handles.ac_calibsave,'enable','off')
	end
	drawnow;
end

function exists = calibration_image_exists(folders,numbi)
exists = false;
for k=1:numel(folders)
	if exist(fullfile(folders{k}, ['PIVlab_calibration' ,' (',num2str(numbi),')', '.tif']),'file')
		exists = true;
	end
end

