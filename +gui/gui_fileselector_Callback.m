function gui_fileselector_Callback(~, ~, ~)
filepath=gui.gui_retr('filepath');
if size(filepath,1) > 1 || gui.gui_retr('video_selection_done') == 1
	try
		gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
	catch
	end
	handles=gui.gui_gethand;
	toggler=gui.gui_retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	if gui.gui_retr('video_selection_done') == 0
		if numel(handles.filenamebox.String) >= selected
			set(handles.filenamebox,'value',selected);
		end
	else
		set(handles.filenamebox,'value',1);
	end
end

