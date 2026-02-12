function cam_rectification_Callback(caller, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
if size(filepath,1) >1
    if strcmpi(caller.Text, 'camera 1')
        gui.put('current_cam_nr',1);
        handles.calib_rect_cam_label.String = 'Current camera: CAMERA 1';
    elseif strcmpi(caller.Text, 'camera 2')
        handles.calib_rect_cam_label.String = 'Current camera: CAMERA 2';
        gui.put('current_cam_nr',2);
    end
    gui.switchui('multip27')
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'No PIV images','You need to load some PIV images first.','modal');
end