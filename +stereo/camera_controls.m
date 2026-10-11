function tags = camera_controls
%CAMERA_CONTROLS Controls whose value belongs to ONE camera in stereo-PIV mode.
%   tags = stereo.camera_controls
% The switches of the camera calibration (marked 'session_only' in gui.generateUI): each camera has
% its own lens calibration, with or without the tilted sensor model. stereo.switch_camera stores and
% restores them with the per-camera data (stereo.camera_data_keys).
tags = {'calib_usecalibration', 'calib_use_tilted_model', 'calib_userectification'};
end
