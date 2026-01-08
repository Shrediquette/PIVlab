function cam_marker_setup_Callback(~, ~, ~)
handles=gui.gethand;
gui.switchui('multip28')
do_charuco_detection = gui.retr('do_charuco_detection');
if isempty (do_charuco_detection)
    do_charuco_detection=0;
end
set(handles.calib_dolivedetect,'Value',do_charuco_detection);