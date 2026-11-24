function change_theme(~,~,~)
% Callback of the colour theme menu (Preferences): the chosen theme is stored (the window no longer
% follows the MATLAB theme, see gui.theme_changed) and all controls are built again in its colours.
num_handle_calls=0;
gui.put('num_handle_calls',num_handle_calls);
handles=gui.gethand;
selected=get(handles.matlab_theme,'Value');
selections=get(handles.matlab_theme,'string');
theme=selections{selected};
%s = settings;
%s.matlab.appearance.MATLABTheme.PersonalValue = theme;
if strcmpi(theme,'dark')
    gui.put('darkmode',1)
    gui.set_preference('dark_mode_theme',1);
else
    gui.put('darkmode',0)
    gui.set_preference('dark_mode_theme',0);
end
gui.rebuild_for_theme(true)
