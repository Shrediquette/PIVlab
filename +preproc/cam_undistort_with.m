function img = cam_undistort_with(img, cam)
%CAM_UNDISTORT_WITH Lens undistortion and rectification with the camera settings struct.
%   img = preproc.cam_undistort_with(img, cam)
%   cam  camera settings from import.cam_settings (also with FromGUI=true), including the
%        tilted camera model. Every analysis path uses this function, so all of them correct
%        the images in the same way.
img = preproc.cam_undistort(img, 'cubic', cam.view, cam.use_calibration, cam.use_rectification, ...
    cam.cameraParams, cam.rectification_tform, cam.use_tilted_model, cam.tilted_D, cam.K_opencv);
end
