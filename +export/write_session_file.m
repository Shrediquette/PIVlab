function write_session_file(file, settings, data, view)
% Writes a PIVlab session file with four variables:
%   pivlab_info      format = 'PIVlab session', format_version, pivlab_version, saved, matlab_release
%   pivlab_settings  all settings (like a settings file, export.write_settings_file)
%   pivlab_data      the session data (gui.session_data_keys): images, results, masks, ...
%   pivlab_view      what was shown: panel, frame, A/B image, zoom, Basic/Advanced mode
% MAT format 7 without compression: measured on 850 MB of session data (2026-10-06) it saves in
% 0.7 s instead of 7.4 s (compressed) or 10.7 s (format 7.3), the file is only about 10 % larger
% (PIV results hardly compress). Format 7.3 only when the data is too large for format 7 (2 GB).
pivlab_info = struct('format', 'PIVlab session', 'format_version', 1, 'pivlab_version', gui.pivlab_version, ...
    'saved', char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')), 'matlab_release', version('-release'));
pivlab_settings = export.settings_with_format(settings);
pivlab_data = data;
pivlab_view = view;
w = whos('pivlab_data');
if w.bytes < 2^31 - 2^24
    save(file, 'pivlab_info', 'pivlab_settings', 'pivlab_data', 'pivlab_view', '-v7', '-nocompression');
else
    save(file, 'pivlab_info', 'pivlab_settings', 'pivlab_data', 'pivlab_view', '-v7.3');
end
end
