function extraction_choice_Callback(hObject, ~, ~)
if get(hObject, 'value') ~= 12 %12 = tangent velocity, the only choice for a circle series
	handles=gui.gethand;
	if get(handles.draw_what, 'value')==3
		set(handles.draw_what, 'value', 1)
	end
end

