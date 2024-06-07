function pass4_size_Callback(hObject, ~, ~)
handles=gui.gethand;
step=str2double(get(hObject,'String'));
set (handles.text128, 'string', int2str(step/2));
piv.dispinterrog

