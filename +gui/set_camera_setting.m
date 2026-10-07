function set_camera_setting(name, value)
% Stores a setting of a camera / trigger settings window (see gui.camera_setting).
camera_settings = gui.retr('camera_settings');
if ~isstruct(camera_settings)
    camera_settings = struct();
end
camera_settings.(name) = value;
gui.put('camera_settings', camera_settings);
end
