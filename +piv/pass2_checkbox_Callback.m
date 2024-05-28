function pass2_checkbox_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject,'Value') == 0
	set(handles.edit50,'enable','off')
	set(handles.edit51,'enable','off')
	set(handles.edit52,'enable','off')
	set(handles.checkbox27,'value',0)
	set(handles.checkbox28,'value',0)
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
else
	set(handles.edit50,'enable','on')
	set(handles.repeat_last,'Enable','on')
	set(handles.edit52x,'Enable','on')
end
piv.piv_dispinterrog

