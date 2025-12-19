function cam_saveparams_Callback(~,~,~)
cameraParams=gui.retr('cameraParams');
cam_selected_target_images = gui.retr('cam_selected_target_images');
if ~isempty(cameraParams) && ~isempty(cam_selected_target_images)
    [filen, pathn] = uiputfile('*.mat','Save camera calibration as...',fullfile(gui.retr('pathname'),'camera_calibration.mat'));
    if filen ~=0
        save(fullfile(pathn,filen),"cameraParams","cam_selected_target_images");
    end
end