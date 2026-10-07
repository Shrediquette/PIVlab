function pivlab_settings = settings_with_format(settings)
% Adds the header of the settings format to a settings struct (gui.collect_settings):
%   format = 'PIVlab settings', format_version, pivlab_version, saved (date).
% Used for settings files and for the settings stored in a session.
pivlab_settings = settings;
pivlab_settings.format = 'PIVlab settings';
pivlab_settings.format_version = 1;
pivlab_settings.pivlab_version = gui.pivlab_version;
pivlab_settings.saved = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
end
