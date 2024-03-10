function extract_area_all_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
if get(hObject,'Value')==1
	set(handles.savearea,'enable','off');
	set(handles.savearea,'value',1);
else
	set(handles.savearea,'enable','on');
end
