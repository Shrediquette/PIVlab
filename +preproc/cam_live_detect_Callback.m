function cam_live_detect_Callback (src,~,~)
gui.put('do_charuco_detection',src.Value);
if src.Value == 0
	delete(findobj('tag','charucolabel'));
end