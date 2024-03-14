function gui_togglepair_Callback(~, ~, ~)
toggler=get(gco, 'value');
gui.gui_put ('toggler',toggler);
filepath=gui.gui_retr('filepath');
capturing=gui.gui_retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	if size(filepath,1) > 1 || gui.gui_retr('video_selection_done') == 1
		gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
		handles=gui.gui_gethand;
		if strncmp(get(handles.multip03, 'visible'), 'on',2)
			preproc.preproc_preview_preprocess_Callback
		end
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		if gui.gui_retr('video_selection_done') == 0
			set(handles.filenamebox,'value',selected);
		else
			set(handles.filenamebox,'value',1);
		end
	end
end

