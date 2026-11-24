function rebuild_for_theme(from_preferences)
% All controls are built again in the colours of gui.retr('darkmode'); the settings, the data and the
% view are kept.
%   from_preferences  true: the colour theme was chosen in the Preferences (gui.change_theme), the
%                     Preferences panel is open afterwards (it also sets the window theme from the
%                     stored preference). false: the window followed the MATLAB theme
%                     (gui.theme_changed), the panel that was open stays open.
num_handle_calls=0;
gui.put('num_handle_calls',num_handle_calls);
settings = gui.collect_settings; % the window is rebuilt below: keep the settings, the data and the view
view = gui.collect_view;

%% Apply fix for wrong UI scaling introduced between matlab 2025a prerelease5 and Matlab2025a
try
    if ~isMATLABReleaseOlderThan("R2025a") && isMATLABReleaseOlderThan("R2025b")
        gui.reset_GUI_sizing
    end
catch
end

gui.destroyUI
gui.generateUI
gui.put('num_handle_calls',0); % fresh handles of the new controls
gui.apply_settings(settings, fieldnames(gui.default_settings), true);

%% Apply fix for wrong UI scaling introduced between matlab 2025a prerelease5 and Matlab2025a
try
    if ~isMATLABReleaseOlderThan("R2025a") && isMATLABReleaseOlderThan("R2025b")
        gui.fix_R2025a_GUI_sizing
        disp('-> Applied GUI scaling bug fix for release 2025a...')
    end
catch
end

gui.MainWindow_ResizeFcn(getappdata(0,'hgui'))
% one panel is opened first: only it is visible while the data is shown again
if from_preferences
    gui.preferences_Callback
    gui.show_data_after_rebuild(view)
else
    gui.switchui('multip01')
    gui.show_data_after_rebuild(view)
    gui.apply_view(struct('panel', view.panel)) % the panel that was open (as for a session)
end
load (fullfile('images','icons.mat'),'parallel_off','parallel_on');
if gui.retr('darkmode')
    parallel_on=1-parallel_on+35/255;
    parallel_off=1-parallel_off+35/255;
    parallel_on(parallel_on>1)=1;
    parallel_off(parallel_off>1)=1;
end
num_handle_calls=0;
gui.put('num_handle_calls',num_handle_calls);
handles=gui.gethand;
if gui.retr('parallel') == 1
    set(handles.toggle_parallel, 'cdata',parallel_on,'TooltipString','Parallel processing on. Click to turn off.');
else
    set(handles.toggle_parallel, 'cdata',parallel_off,'TooltipString','Parallel processing off. Click to turn on.');
end
gui.toolsavailable(0) % as at the start: remembers the disabled controls of the new window (a later
gui.toolsavailable(1) % gui.toolsavailable(1) would otherwise enable them) and enables the others again
