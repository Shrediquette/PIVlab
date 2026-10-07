function value = camera_setting(name)
% A setting of a camera / trigger settings window (bits, gain, file type, trigger mode, ...).
% All of them are kept in one struct (appdata 'camera_settings'), which is saved and loaded with
% the settings of the group 'acquisition' (gui.collect_settings / gui.apply_settings).
% Returns [] if the setting was not set yet (the camera code then uses its own default).
value = [];
camera_settings = gui.retr('camera_settings');
if isstruct(camera_settings) && isfield(camera_settings, name)
    value = camera_settings.(name);
end
end
