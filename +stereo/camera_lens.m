function [cam, message] = camera_lens(camera)
%CAMERA_LENS Lens calibration of one camera of the GUI (a stereo camera state) as camera settings.
%   [cam, message] = stereo.camera_lens(camera)
%   camera   per-camera data (stereo.collect_camera / gui.retr('stereo_cam_state'){k})
%   cam      import.cam_settings with the lens calibration (MATLAB model or tilted OpenCV model),
%            [] if the camera has no lens calibration; message says why
% The lens calibration counts when it exists ("Estimate cam parameters" or "Load parameters"), also
% when "Enable camera calibration" is not ticked: stereo-PIV always undistorts the images.
cam = [];
message = '';
if ~isfield(camera, 'cameraParams') || isempty(camera.cameraParams)
    message = 'no lens calibration ("Estimate cam parameters" or "Load parameters" in the camera calibration panel)';
    return
end
use_tilted = isfield(camera, 'cam_use_tilted_model') && isequal(double(camera.cam_use_tilted_model), 1) ...
    && ~isempty(camera.cam_tilted_D) && ~isempty(camera.cam_K_opencv);
tilted_D = [];
K_opencv = [];
if use_tilted
    tilted_D = camera.cam_tilted_D;
    K_opencv = camera.cam_K_opencv;
end
cam = import.cam_settings(view='same', use_calibration=1, cameraParams=camera.cameraParams, ...
    use_tilted_model=use_tilted, tilted_D=tilted_D, K_opencv=K_opencv);
end
