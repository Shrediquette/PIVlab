function draw_what_Callback(hObject, ~, ~)
handles=gui.gethand;
if get(hObject, 'value') == 3 %circle series: only tangential velocity
	set (handles.extraction_choice, 'value', 11);
end
gui.update_dependent_controls(handles)
