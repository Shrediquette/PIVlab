function vector_scale_Callback (caller,~,~)
handles=gui.gethand;

if strcmpi(caller.Tag,'uniform_vector_scale')
	if caller.Value ==1
		set(handles.power_vector_scale,'Value',0);
	end
elseif strcmpi(caller.Tag,'power_vector_scale')
	if caller.Value ==1
		set(handles.uniform_vector_scale,'Value',0);
	end
elseif strcmpi(caller.Tag,'power_vector_scale_factor')
	if isfinite(str2double(caller.String))
		misc.check_comma(caller)
		if str2double(caller.String)>2
			set(caller,'String','1')
		end
	else
		set(caller,'String','1')
	end
end