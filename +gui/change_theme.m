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
    setpref('PIVlab_ad','dark_mode_theme',1);
else
    gui.put('darkmode',0)
    setpref('PIVlab_ad','dark_mode_theme',0);
end

%% Apply fix for wrong UI scaling introduced between matlab 2025a prerelease5 and Matlab2025a
try
    if ~isMATLABReleaseOlderThan("R2025a")
        gui.reset_GUI_sizing
    end
catch
end

gui.destroyUI
gui.generateUI

%% Apply fix for wrong UI scaling introduced between matlab 2025a prerelease5 and Matlab2025a
try
    if ~isMATLABReleaseOlderThan("R2025a")
        gui.fix_R2025a_GUI_sizing
        disp('-> Applied GUI scaling bug fix for release 2025a...')
    end
catch
end

gui.MainWindow_ResizeFcn(gcf)
gui.preferences_Callback
gui.clear_user_content
gui.displogo(1)
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
