function keys = setup_keys
%SETUP_KEYS Per-camera data that belongs to the camera setup, not to the images (lens calibration, board image).
%   keys = stereo.setup_keys
% Kept when new images of the same cameras (same image size) are imported: stereo-PIV and two cameras
% combined into a larger field of view (fov.enter_combined).
keys = {'cameraParams', 'cameraStats', 'cam_use_calibration', 'cam_use_rectification', 'cam_use_tilted_model', ...
    'cam_tilted_D', 'cam_K_opencv', 'rectification_tform', 'cam_selected_target_images', ...
    'cam_selected_rectification_image', 'charuco_qr_params', 'controls'};
end
