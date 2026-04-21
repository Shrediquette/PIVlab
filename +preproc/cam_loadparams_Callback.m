function cam_loadparams_Callback(~,~,~)
handles=gui.gethand;
[filen, pathn] = uigetfile('*.mat','Load camera calibration',fullfile(gui.retr('pathname'),'camera_calibration.mat'));
if filen ~=0
    loaded = load(fullfile(pathn,filen));
    gui.put('cameraParams',               loaded.cameraParams);
    gui.put('cam_selected_target_images', loaded.cam_selected_target_images);
    % Tilted model parameters (absent in files saved before this feature)
    if isfield(loaded, 'cam_use_tilted_model')
        gui.put('cam_use_tilted_model', loaded.cam_use_tilted_model);
        gui.put('cam_tilted_D',         loaded.cam_tilted_D);
        gui.put('cam_K_opencv',         loaded.cam_K_opencv);
        handles.calib_use_tilted_model.Value = loaded.cam_use_tilted_model;
    else
        gui.put('cam_use_tilted_model', false);
        gui.put('cam_tilted_D',         []);
        gui.put('cam_K_opencv',         []);
        handles.calib_use_tilted_model.Value = 0;
    end
    handles.calib_usecalibration.Value = 0;
end