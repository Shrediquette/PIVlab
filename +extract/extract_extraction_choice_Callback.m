function extract_extraction_choice_Callback(hObject, ~, ~)
if get(hObject, 'value') ~= 11
	handles=gui.gui_gethand;
	if get(handles.draw_what, 'value')==3
		set(handles.draw_what, 'value', 1)
	end
end

