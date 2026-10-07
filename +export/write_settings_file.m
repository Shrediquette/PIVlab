function write_settings_file(file, settings)
% Writes a PIVlab settings file: one variable pivlab_settings with
%   format = 'PIVlab settings', format_version, pivlab_version, saved (date),
%   one struct per group of settings (see gui.default_settings), popup_texts,
%   calibration_data (end points of the reference distance, offsets).
% settings: struct from gui.collect_settings (+ calibration_data).
pivlab_settings = export.settings_with_format(settings); %#ok<NASGU>
save(file, 'pivlab_settings', '-v7');
end
