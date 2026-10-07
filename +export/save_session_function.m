function save_session_function (PathName,FileName)
% Saves the session: all settings, the session data (gui.session_data_keys) and the view,
% in the format of export.write_session_file.
gui.toolsavailable(1)
gui.toolsavailable(0,'Busy, saving session...');drawnow
settings = gui.collect_settings;
settings.calibration_data = calibrate.calibration_data;
keys = gui.session_data_keys;
data = struct();
for i=1:numel(keys)
	data.(keys{i}) = gui.retr(keys{i});
end
export.write_session_file(fullfile(PathName,FileName), settings, data, gui.collect_view);
gui.toolsavailable(1)
drawnow;
