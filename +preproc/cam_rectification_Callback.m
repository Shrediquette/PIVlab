function cam_rectification_Callback(caller, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
if size(filepath,1) >1
    if isequal(gui.retr('stereomode'), 1) % stereo-PIV: the menu entry selects the camera
        if strcmpi(caller.Text, 'camera 2')
            stereo.switch_camera(2);
        else
            stereo.switch_camera(1);
        end
    else
        handles.calib_rect_cam_label.String = 'Current camera: CAMERA 1';
    end
    gui.switchui('multip27')
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'No PIV images','You need to load some PIV images first.','modal');
end
