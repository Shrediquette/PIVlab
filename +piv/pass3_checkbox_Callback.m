function pass3_checkbox_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject,'Value') == 0 %without pass 3 there is no pass 4
	set(handles.pass4_enable,'value',0)
	set(handles.repeat_last_enable,'Value',0)
else %pass 3 needs pass 2
	set(handles.pass2_enable,'value',1)
end
gui.update_dependent_controls(handles)
piv.dispinterrog
