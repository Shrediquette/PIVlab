function cam_change_viewtype_Callback(~,~,~)
handles=gui.gethand;
if handles.calib_usecalibration.Value == 1
    preproc.cam_enable_cam_calib_Callback('calib_viewtype')
end