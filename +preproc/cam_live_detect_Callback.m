function cam_live_detect_Callback (src,~,~)
gui.put('do_charuco_detection',src.Value);
if src.Value == 0
	delete(findobj('-regexp','tag','^charucolabel')); %also the labels per camera (stereo acquisition)
else %Calibration and Sharpness exclude each other (too much information on the screen, slow)
	handles = gui.gethand;
	if handles.ac_displ_sharp.Value == 1
		handles.ac_displ_sharp.Value = 0;
		acquisition.display_cam_overlay_Callback(handles.ac_displ_sharp);
	end
end
