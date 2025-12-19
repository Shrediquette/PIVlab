function cam_loadparams_Callback(~,~,~)
handles=gui.gethand;
[filen, pathn] = uigetfile('*.mat','Load camera calibration',fullfile(gui.retr('pathname'),'camera_calibration.mat'));
if filen ~=0
    load(fullfile(pathn,filen),"cameraParams","cam_selected_target_images")
    gui.put('cameraParams',cameraParams);
    gui.put('cam_selected_target_images',cam_selected_target_images);
    handles.calib_usecalibration.Value = 0;
    if strcmpi (class(cameraParams),'cameraParameters')
        handles.calib_fisheye.Value = 0;
    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        handles.calib_fisheye.Value = 1;
    end
end