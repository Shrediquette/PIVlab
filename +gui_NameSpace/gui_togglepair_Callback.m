function gui_togglepair_Callback(~, ~, ~)
toggler=get(gco, 'value');
gui_NameSpace.gui_put ('toggler',toggler);
filepath=gui_NameSpace.gui_retr('filepath');
capturing=gui_NameSpace.gui_retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	if size(filepath,1) > 1 || gui_NameSpace.gui_retr('video_selection_done') == 1
		gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
		handles=gui_NameSpace.gui_gethand;
		if strncmp(get(handles.multip03, 'visible'), 'on',2)
			preproc_NameSpace.preproc_preview_preprocess_Callback
		end
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		if gui_NameSpace.gui_retr('video_selection_done') == 0
			set(handles.filenamebox,'value',selected);
		else
			set(handles.filenamebox,'value',1);
		end
	end
end
