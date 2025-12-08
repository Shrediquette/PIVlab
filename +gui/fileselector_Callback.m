function fileselector_Callback(~, ~, ~)
filepath=gui.retr('filepath');
if size(filepath,1) > 1 || gui.retr('video_selection_done') == 1
	try
		gui.sliderdisp(gui.retr('pivlab_axis'))
	catch
	end
	handles=gui.gethand;
	toggler=gui.retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	if gui.retr('video_selection_done') == 0
		if numel(handles.filenamebox.String) >= selected
			set(handles.filenamebox,'value',selected);
		end
	else
		set(handles.filenamebox,'value',1);
	end
end