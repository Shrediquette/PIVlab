function pass4_checkbox_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value') == 0
	set(handles.repeat_last_enable,'Value',0)
else %pass 4 needs pass 2 and 3
	set(handles.pass2_enable,'value',1)
	set(handles.pass3_enable,'value',1)
end
gui.update_dependent_controls(handles)
piv.dispinterrog
