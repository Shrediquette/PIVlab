function ensemble_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value') ==1
	set(handles.dcc,'value',0)
	set(handles.fftmulti,'value',0)
	set(handles.uipanel42,'visible','on')
	set(handles.CorrQuality,'visible','on')
	set(handles.text914,'visible','on')
	set(handles.mask_auto_box,'visible','on')
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
	%set(handles.AnalyzeAll,'visible','off')
	set(handles.AnalyzeSingle,'visible','off')
	set(handles.Settings_Apply_current,'visible','off')
else
	set(handles.ensemble,'value',1)
end
piv.dispinterrog

