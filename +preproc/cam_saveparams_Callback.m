function cam_saveparams_Callback(~,~,~)
cameraParams               = gui.retr('cameraParams');
cam_selected_target_images = gui.retr('cam_selected_target_images');
cam_use_tilted_model       = gui.retr('cam_use_tilted_model');
cam_tilted_D               = gui.retr('cam_tilted_D');
cam_K_opencv               = gui.retr('cam_K_opencv');
if ~isempty(cameraParams) && ~isempty(cam_selected_target_images)
    [filen, pathn] = uiputfile('*.mat','Save camera calibration as...',fullfile(gui.retr('pathname'),'camera_calibration.mat'));
    if filen ~=0
        save(fullfile(pathn,filen),"cameraParams","cam_selected_target_images","cam_use_tilted_model","cam_tilted_D","cam_K_opencv");
    end
end