function keys = camera_data_keys
%CAMERA_DATA_KEYS Session data that belongs to ONE camera in stereo-PIV mode.
%   keys = stereo.camera_data_keys
% A subset of gui.session_data_keys. stereo.switch_camera stores these entries of the active camera
% and loads the ones of the other camera; everything else (all settings, ROI, calibration px -> mm,
% results, display) is shared by both cameras.
keys = {};
keys = [keys, {'filepath', 'filename', 'framenum', 'framepart', 'multitiff', 'pcopanda_dbl_image', ...
    'video_selection_done', 'video_frame_selection', 'expected_image_size', 'size_of_the_image'}]; % images
keys = [keys, {'masks_in_frame'}]; % masks are drawn per camera
keys = [keys, {'bg_img_A', 'bg_img_B'}]; % background images (raw camera images in stereo mode)
keys = [keys, {'cameraParams', 'cameraStats', 'cam_use_calibration', 'cam_use_rectification', 'cam_use_tilted_model', ...
    'cam_tilted_D', 'cam_K_opencv', 'rectification_tform', 'cam_selected_target_images', ...
    'cam_selected_rectification_image', 'charuco_qr_params'}]; % lens calibration and board in the light sheet
keys = [keys, {'stereo_result'}]; % 2D PIV result of this camera (stereo.per_camera)
keys = [keys, {'stereo_check'}]; % 2D check result of this camera before the stereo calibration (stereo.check_result)
end
