function reset_to_defaults()
% reset_to_defaults  Revert all GUI controls to their default values.
%
% Reloads PIVlab_settings_default.mat exactly as PIVlab does at startup, which
% resets every saved control and replays the conditional-visibility callbacks
% it manages (PIV algorithm, multipass).  The mask-mode popups are not part of
% the saved settings, so they are reset explicitly here.
%
% Analysis results (resultslist) are NOT touched — only settings revert.

% Reload the default settings file (same path resolution as PIVlab_GUI startup)
try
    psdfile = which('PIVlab_settings_default.mat');
    dindex  = strfind(psdfile, filesep);
    import.read_settings('PIVlab_settings_default.mat', psdfile(1:(dindex(end)-1)));
catch
    disp('reset_to_defaults: could not reload default settings')
end

% read_settings does not manage the mask-mode popups — reset them to defaults
% so the mask panel returns to its default (Basic / Bright area) appearance.
handles = gui.gethand;
try
    set(handles.mask_basic_expert,  'Value', 1);   % Basic
    set(handles.mask_bright_or_dark,'Value', 1);   % Bright area mask generator
    mask.basic_expert_Callback;                     % syncs uipanel25_1/2/9/10
catch
end
end
