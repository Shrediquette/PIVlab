function togglepair_Callback(~, ~, ~)
toggler=get(gco, 'value');
gui.put ('toggler',toggler);
filepath=gui.retr('filepath');
capturing=gui.retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	if size(filepath,1) > 1 || gui.retr('video_selection_done') == 1
		gui.sliderdisp(gui.retr('pivlab_axis'))
		handles=gui.gethand;
		if strncmp(get(handles.multip03, 'visible'), 'on',2)
			preproc.preview_preprocess_Callback
		end
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		if gui.retr('video_selection_done') == 0
			set(handles.filenamebox,'value',selected);
		else
			set(handles.filenamebox,'value',1);
		end
	end
end

