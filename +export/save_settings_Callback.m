function save_settings_Callback(~, ~, ~)
% File -> Save settings: all settings of the PIVlab window (all groups, see gui.default_settings)
% and the calibration data, in the format of export.write_settings_file.
if ispc==1
	username = getenv('USERNAME');
else
	username = getenv('USER');
end
[FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PIVlab_set_' username '.mat']);
if isequal(FileName,0)
	return
end
settings = gui.collect_settings;
settings.calibration_data = calibrate.calibration_data;
export.write_settings_file(fullfile(PathName,FileName), settings);
end
