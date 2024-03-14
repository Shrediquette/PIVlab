function piv_pass3_size_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
step=str2double(get(hObject,'String'));
set (handles.text127, 'string', int2str(step/2));
piv.piv_dispinterrog

