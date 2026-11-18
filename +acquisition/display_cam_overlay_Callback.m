function display_cam_overlay_Callback (A,~,~)
if strcmpi (A.Tag, 'ac_displ_sharp')
	gui.put('sharpness_enabled',A.Value);
	if A.Value == 1 %Sharpness and Calibration exclude each other (too much information on the screen, slow)
		handles = gui.gethand;
		if handles.calib_dolivedetect.Value == 1
			handles.calib_dolivedetect.Value = 0;
			preproc.cam_live_detect_Callback(handles.calib_dolivedetect);
		end
	end
end
if strcmpi (A.Tag, 'ac_displ_grid')
	gui.put('crosshair_enabled',A.Value);
end
