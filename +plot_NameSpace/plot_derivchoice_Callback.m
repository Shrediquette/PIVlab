function plot_derivchoice_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
contents = get(hObject,'String');
currstring=contents{get(hObject,'Value')};
currstring=currstring(strfind(currstring,'['):end);
set(handles.text39,'String', ['min ' currstring ':']);
set(handles.text40,'String', ['max ' currstring ':']);
plot_NameSpace.plot_derivdropdown(hObject);
