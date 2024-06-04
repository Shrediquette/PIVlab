function area_all_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value')==1
	set(handles.savearea,'enable','off');
	set(handles.savearea,'value',1);
else
	set(handles.savearea,'enable','on');
end

