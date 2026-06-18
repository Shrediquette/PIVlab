function switched = request_mode_switch(new_mode)
% request_mode_switch  Handle an interactive Basic/Advanced mode change.
%
% Switching modes resets all GUI settings to their defaults.  If the user has
% already produced analysis results (resultslist populated), a confirmation
% dialog is shown first, because those results were produced with the current
% (about to be reset) settings.  With no results there is nothing to lose, so
% the switch happens silently.
%
% Returns true if the mode was actually switched, false if unchanged/cancelled.

switched = false;
hgui = getappdata(0,'hgui');

current = gui.retr('ui_mode');
if isempty(current); current = 'advanced'; end
if strcmp(new_mode, current)
    return   % already in this mode — nothing to do
end

% Warn only when there is analysis work that the reset could devalue.
resultslist = gui.retr('resultslist');
if ~isempty(resultslist)
    answer = gui.custom_msgbox('quest', hgui, 'Switch interface mode', ...
        ['Switching the interface mode resets all settings to their defaults.' newline newline ...
         'Your analysis results are kept, but the settings that produced them ' ...
         'will be reverted.' newline newline 'Continue?'], ...
        'modal', {'Yes','No'}, 'No');
    if ~strcmp(answer, 'Yes')
        return   % user cancelled — leave everything as it is
    end
end

gui.reset_to_defaults();
gui.apply_ui_mode(new_mode);

% Remember the choice in the default settings file (consistent with the rest
% of PIVlab's settings storage).
ui_mode = new_mode;
try
    save('PIVlab_settings_default.mat','ui_mode','-append');
catch
end

switched = true;
end
