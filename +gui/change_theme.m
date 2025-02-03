function change_theme(~,~,~)
num_handle_calls=0;
gui.put('num_handle_calls',num_handle_calls);
handles=gui.gethand;
selected=get(handles.matlab_theme,'Value');
selections=get(handles.matlab_theme,'string');
theme=selections{selected};
s = settings;
s.matlab.appearance.MATLABTheme.PersonalValue = theme;
if strcmpi(theme,'dark')
	gui.put('darkmode',1)
else
	gui.put('darkmode',0)
end
gui.destroyUI
gui.generateUI
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