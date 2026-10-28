function cam_rectification_Callback(~, ~, ~)
handles=gui.gethand;
filepath=gui.retr('filepath');
if size(filepath,1) >1
    if ~isequal(gui.retr('stereomode'), 1) % stereo-PIV: the panel is for the active camera (label set in update_dependent_controls)
        handles.calib_rect_cam_label.String = 'Current camera: CAMERA 1';
    end
    gui.switchui('multip27')
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'No PIV images','You need to load some PIV images first.','modal');
end
