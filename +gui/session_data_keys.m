function keys = session_data_keys
% The data of a session that is not a setting (the one list; settings are found automatically,
% see gui.collect_settings). Saving a session stores exactly these appdata entries of the PIVlab
% window, loading a session clears and sets exactly these entries.
% Not stored: handles, hardware objects (serial port, camera, video reader), caches.
keys = {};
keys = [keys, {'filepath', 'filename', 'framenum', 'framepart', 'sequencer', 'multitiff', 'pcopanda_dbl_image', 'video_selection_done', 'video_frame_selection', 'expected_image_size'}]; % images
keys = [keys, {'resultslist', 'derived', 'ismean'}]; % results
keys = [keys, {'roirect', 'masks_in_frame', 'velrect', 'velrect_freehand', 'manualdeletion', 'framemanualdeletion'}]; % exclusions
keys = [keys, {'bg_img_A', 'bg_img_B'}]; % pre-processing
keys = [keys, {'calu', 'calv', 'calxy', 'offset_x_true', 'offset_y_true', 'pointscali', 'points_offsetx', 'points_offsety', 'displacement_only', 'size_of_the_image', 'caliimg'}]; % calibration
keys = [keys, {'cameraParams', 'cameraStats', 'cam_use_calibration', 'cam_use_rectification', 'cam_use_tilted_model', 'cam_tilted_D', 'cam_K_opencv', 'rectification_tform', 'cam_selected_target_images', 'cam_selected_rectification_image', 'charuco_qr_params'}]; % camera calibration and rectification
keys = [keys, {'displaywhat', 'subtr_u', 'subtr_v', 'streamlinesX', 'streamlinesY', 'streamslice_active', 'manmarkersX', 'manmarkersY', 'xposition', 'yposition', 'extract_type'}]; % display and tools
keys = [keys, {'stereomode'}]; % stereo-PIV
end
