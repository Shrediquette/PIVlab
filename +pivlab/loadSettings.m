function [s, filetype] = loadSettings(file)
%LOADSETTINGS Read analysis settings from a PIVlab settings file or a PIVlab session.
%   s = pivlab.loadSettings(file) detects automatically whether file is a settings file
%   ("File -> Save settings" in PIVlab) or a session file
%   ("File -> Save session") and returns the settings in the format of pivlab.defaults.
%   Settings that the file does not contain keep their default values.
%
%   [s, filetype] = pivlab.loadSettings(file) also returns 'settings' or 'session'.
%
%   From a session, the region of interest (s.preprocess.Roi), the background subtraction mode
%   (s.preprocess.Background) and the velocity limits (s.filter.VelocityLimits) are read as well.
%   Velocity and notch limits stored by PIVlab are in calibrated units; pivlab.filter converts
%   them when they are applied to results in other units (s.filter.LimitUnits = "calibrated").
%
%   Example
%       s = pivlab.loadSettings("my_session.mat");
%       imgs = pivlab.preprocess(pivlab.readImages("C:\data\*.tif","pairwise"), Settings=s);
%       res  = pivlab.analyze(imgs, Settings=s);
%
%   See also pivlab.defaults, pivlab.loadSession
arguments
    file {mustBeTextScalar}
end
file = char(file);
if ~isfile(file)
    error('pivlab:loadSettings:notFound','File not found: %s', file);
end
s = pivlab.defaults();
[session, message] = import.read_session_file(file);
if ~isempty(session)
    filetype = 'session';
    s = gui_settings_to_api(session.settings, s);
    s = session_extras(s, session.data);
else
    [G, message] = import.read_settings_file(file);
    if isempty(G)
        vars = who('-file', file);
        if any(ismember({'u_original','u_filtered','typevector_original'}, vars))
            error('pivlab:loadSettings:noSettings', ...
                ['%s is a MAT file exported from PIVlab. It contains results, but no settings.' newline ...
                'Use a PIVlab session or settings file instead.'], file);
        end
        error('pivlab:loadSettings:unknownFile', '%s: %s', file, message);
    end
    filetype = 'settings';
    s = gui_settings_to_api(G, s);
end
s.source = string(file);
end
