function gui_fileselector_Callback(~, ~, ~)
filepath=gui_NameSpace.gui_retr('filepath');
if size(filepath,1) > 1 || gui_NameSpace.gui_retr('video_selection_done') == 1
	try
		gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
	catch
	end
	handles=gui_NameSpace.gui_gethand;
	toggler=gui_NameSpace.gui_retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	if gui_NameSpace.gui_retr('video_selection_done') == 0
		if numel(handles.filenamebox.String) >= selected
			set(handles.filenamebox,'value',selected);
		end
	else
		set(handles.filenamebox,'value',1);
	end
end
