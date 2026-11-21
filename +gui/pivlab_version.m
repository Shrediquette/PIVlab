function [version, isbeta] = pivlab_version
% The version of PIVlab (shown in the window title, written into settings files and sessions).
version = '4.0.2';
% Beta flag: 1 = beta build ("BETA VERSION" is shown at startup), 0 = regular release.
% Set this to 0 together with the version number before a non-beta release.
isbeta = 1;
end
