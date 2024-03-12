function extract_draw_what_Callback(hObject, ~, ~)
handles=gui.gui_gethand;
if get(hObject, 'value') == 3
	handles=gui.gui_gethand;
	set (handles.extraction_choice, 'value', 11);
	set (handles.extraction_choice, 'enable', 'off');
else
	set (handles.extraction_choice, 'enable', 'on');
end

