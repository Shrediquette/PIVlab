function set_other_interpol_checkbox(hObject,~,~) %synchronizes the two existing "interpolate missing data" checkboxes
handles=gui.gethand;
set(handles.interpol_missing,'Value',get(hObject,'Value'));
gui.update_dependent_controls(handles) %interpol_missing2 shows the same setting
