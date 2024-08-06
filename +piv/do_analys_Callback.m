function do_analys_Callback(~, ~, ~)
handles=gui.gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
if get(handles.algorithm_selection,'Value') == 1 || get(handles.algorithm_selection,'Value') == 3 %fft multi or dcc
	set(handles.AnalyzeAll,'String','Analyze all frames');
end
if get(handles.algorithm_selection,'Value') == 2 %ensemble
	set(handles.AnalyzeAll,'String','Start ensemble analysis');
end
if gui.retr('parallel')==1
	set(handles.update_display_checkbox,'Visible','Off')
end
gui.switchui('multip05')

