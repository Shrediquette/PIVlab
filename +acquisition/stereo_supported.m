function supported = stereo_supported(camera_type)
%STEREO_SUPPORTED True when PIVlab can record stereo-PIV images with two cameras of this type.
%   Stereo acquisition: two cameras of the same type, both on the camera output of the synchronizer
%   (Y-cable), so the timing is the same as with one camera.
%   OPTRONIS: two Cyclone-2-2000-M on one BitFlow grabber (two CoaXPress links per camera).
supported = any(strcmp(camera_type, {'OPTOcam', 'OPTOcam_20_9'})) ...
    || (strcmp(camera_type, 'OPTRONIS') && strcmp(gui.retr('camera_sub_type'), 'Cyclone-2-2000-M-bitflow'));
end
