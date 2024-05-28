function fftmulti_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject,'Value') ==1
	set(handles.dcc,'value',0)
	set(handles.ensemble,'value',0)
	set(handles.uipanel42,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')
	if get(handles.checkbox26,'value') ~=0
		set(handles.repeat_last,'Enable','on')
		set(handles.edit52x,'Enable','on')
	end
else
	set(handles.fftmulti,'value',1)
end
piv.piv_dispinterrog

