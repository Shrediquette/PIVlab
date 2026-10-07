function pass2_checkbox_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value') == 0 %without pass 2 there is no pass 3 and 4
	set(handles.pass3_enable,'value',0)
	set(handles.pass4_enable,'value',0)
	set(handles.repeat_last_enable,'Value',0)
end
gui.update_dependent_controls(handles)
piv.dispinterrog
