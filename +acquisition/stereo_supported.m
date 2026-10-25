function supported = stereo_supported(camera_type)
%STEREO_SUPPORTED True when PIVlab can record stereo-PIV images with two cameras of this type.
%   Stereo acquisition: two cameras of the same type, both on the camera output of the synchronizer
%   (Y-cable), so the timing is the same as with one camera.
supported = any(strcmp(camera_type, {'OPTOcam'}));
end
