function do_analys_Callback(~, ~, ~)
handles=gui.gui_gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
if get(handles.fftmulti,'Value') == 1 || get(handles.dcc,'Value') == 1
	set(handles.AnalyzeAll,'String','Analyze all frames');
end
if get(handles.ensemble,'Value') == 1
	set(handles.AnalyzeAll,'String','Start ensemble analysis');
end
if gui.gui_retr('parallel')==1
	set(handles.update_display_checkbox,'Visible','Off')
end
gui.gui_switchui('multip05')

