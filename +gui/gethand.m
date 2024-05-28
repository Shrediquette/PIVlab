function handles=gethand
hgui=getappdata(0,'hgui');
num_handle_calls=gui.gui_retr('num_handle_calls');
if ~isempty(num_handle_calls)
	if num_handle_calls<20
		num_handle_calls = num_handle_calls + 1;
		gui.gui_put('num_handle_calls',num_handle_calls);
	end
else
	num_handle_calls=0;
	gui.gui_put('num_handle_calls',num_handle_calls);
end
if num_handle_calls<20
	handles=guihandles(hgui);
	gui.gui_put('existing_handles',handles);
	%disp('getting fresh handles')
else
	handles=gui.gui_retr('existing_handles');
	%disp('_getting old handles')
end

