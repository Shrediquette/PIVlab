function piv_pass2_size_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
step=str2double(get(hObject,'String'));
set (handles.text126, 'string', int2str(step/2));
piv.piv_dispinterrog

