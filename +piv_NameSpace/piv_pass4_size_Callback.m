function piv_pass4_size_Callback(hObject, ~, ~)
handles=gui_NameSpace.gui_gethand;
step=str2double(get(hObject,'String'));
set (handles.text128, 'string', int2str(step/2));
piv_NameSpace.piv_dispinterrog
