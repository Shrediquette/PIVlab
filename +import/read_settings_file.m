function [settings, message] = read_settings_file(file)
% Reads a PIVlab settings file (export.write_settings_file). A PIVlab session can be read as well
% (its settings are returned).
%   settings  struct with one field per group of settings, popup_texts, calibration_data;
%             [] if the file is not a PIVlab settings file or session of this version
%   message   '' or the reason why the file cannot be read (for the user)
settings = [];
message = '';
try
    vars = who('-file', file);
catch
    message = 'This is not a MATLAB file.';
    return
end
if ismember('pivlab_settings', vars)
    loaded = load(file, 'pivlab_settings');
    candidate = loaded.pivlab_settings;
else
    candidate = [];
end
if ~isstruct(candidate) || ~isfield(candidate, 'format') || ~strcmp(candidate.format, 'PIVlab settings')
    if any(ismember({'intarea', 'clahe_enable', 'stepsize', 'resultslist'}, vars))
        message = 'This file was saved with an older PIVlab version (3.x or older) and cannot be opened in this version.';
    else
        message = 'This is not a PIVlab settings file.';
    end
    return
end
settings = candidate;
end

