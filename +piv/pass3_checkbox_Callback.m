function pass3_checkbox_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value') == 0
	set(handles.edit51,'enable','off')
	set(handles.edit52,'enable','off')
	set(handles.checkbox28,'value',0)
	set(handles.repeat_last,'Value',0)
	set(handles.repeat_last,'Enable','off')
	set(handles.edit52x,'Enable','off')
else
	set(handles.edit50,'enable','on')
	set(handles.edit51,'enable','on')
	set(handles.checkbox26,'value',1)
	set(handles.repeat_last,'Enable','on')
	set(handles.edit52x,'Enable','on')
end
if get(handles.checkbox26,'value')==0
	set(handles.checkbox27,'value',0)
	set(handles.edit51,'enable','off')
end
piv.dispinterrog

