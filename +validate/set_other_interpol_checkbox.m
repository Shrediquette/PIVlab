function set_other_interpol_checkbox(hObject,~,~) %synchronizes the two existing "interpoalte missing data" checkboxes
handles=gui.gui_gethand;
set(handles.interpol_missing,'Value',get(hObject,'Value'));
set(handles.interpol_missing2,'Value',get(hObject,'Value'));

