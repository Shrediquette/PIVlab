function change_theme(~,~,~)
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
gui.preferences_Callback % open the preferences panel first: only it is visible while the data is shown again
gui.show_data_after_rebuild(view)
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
