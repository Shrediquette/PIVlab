function img = cam_undistort_with(img, cam)
%CAM_UNDISTORT_WITH Lens undistortion and rectification with the camera settings struct.
%   img = preproc.cam_undistort_with(img, cam)
%   cam  camera settings from import.cam_settings (also with FromGUI=true), including the
%        tilted camera model. Every analysis path uses this function, so all of them correct
%        the images in the same way.
%   Stereo-PIV: when cam.stereo_map is set (stereo.rectified_images), the lens undistortion, the
%   rectification onto the common grid of both cameras and the disparity correction are done in
%   one interpolation with that map (stereo.rectify_map).
if isfield(cam, 'stereo_map') && ~isempty(cam.stereo_map)
    img = stereo.rectify_map(img, cam.stereo_map);
    return
end
img = preproc.cam_undistort(img, 'cubic', cam.view, cam.use_calibration, cam.use_rectification, ...
    cam.cameraParams, cam.rectification_tform, cam.use_tilted_model, cam.tilted_D, cam.K_opencv);
end
