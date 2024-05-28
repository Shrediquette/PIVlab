function dcc_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject,'Value')==1
	set(handles.fftmulti,'value',0)
	set(handles.ensemble,'value',0)

	set(handles.uipanel42,'visible','off')
	set(handles.CorrQuality,'visible','off')
	set(handles.text914,'visible','off')
	set(handles.mask_auto_box,'visible','off')
	%set(handles.AnalyzeAll,'visible','on')
	set(handles.AnalyzeSingle,'visible','on')
	set(handles.Settings_Apply_current,'visible','on')

else
	set(handles.dcc,'value',1)
end
piv.piv_dispinterrog

