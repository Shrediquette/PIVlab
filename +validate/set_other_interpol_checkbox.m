function set_other_interpol_checkbox(hObject,~,~) %synchronizes the "interpolate missing data" checkboxes of the three validation panels
handles=gui.gethand;
set(handles.interpol_missing,'Value',get(hObject,'Value'));
gui.update_dependent_controls(handles) %interpol_missing2 and interpol_missing3 show the same setting
