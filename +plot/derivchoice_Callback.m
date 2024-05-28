function derivchoice_Callback(hObject, ~, ~)
handles=gui.gethand;
contents = get(hObject,'String');
currstring=contents{get(hObject,'Value')};
currstring=currstring(strfind(currstring,'['):end);
set(handles.text39,'String', ['min ' currstring ':']);
set(handles.text40,'String', ['max ' currstring ':']);
plot.derivdropdown(hObject);

