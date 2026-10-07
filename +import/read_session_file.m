function [session, message] = read_session_file(file)
% Reads a PIVlab session file (export.write_session_file).
%   session  struct with info, settings, data, view; [] if the file is not a session of this version
%   message  '' or the reason why the file cannot be read (for the user)
session = [];
message = '';
try
    vars = who('-file', file);
catch
    message = 'This is not a MATLAB file.';
    return
end
if ~all(ismember({'pivlab_info', 'pivlab_settings', 'pivlab_data'}, vars))
    if ismember('resultslist', vars)
        message = 'This session was saved with an older PIVlab version (3.x or older) and cannot be opened in this version.';
    else
        message = 'This is not a PIVlab session file.';
    end
    return
end
loaded = load(file, 'pivlab_info');
if ~isfield(loaded.pivlab_info, 'format') || ~strcmp(loaded.pivlab_info.format, 'PIVlab session')
    message = 'This is not a PIVlab session file.';
    return
end
want = {'pivlab_info', 'pivlab_settings', 'pivlab_data'};
if ismember('pivlab_view', vars)
    want{end+1} = 'pivlab_view';
end
loaded = load(file, want{:});
session.info = loaded.pivlab_info;
session.settings = loaded.pivlab_settings;
session.data = loaded.pivlab_data;
session.view = struct();
if isfield(loaded, 'pivlab_view')
    session.view = loaded.pivlab_view;
end
end
