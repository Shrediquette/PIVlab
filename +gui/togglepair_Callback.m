function togglepair_Callback(caller, ~, ~)
handles=gui.gethand;
toggler=get(caller, 'value');
gui.put ('toggler',toggler);
filepath=gui.retr('filepath');
capturing=gui.retr('capturing');
if isempty(capturing)
	capturing=0;
end
if capturing==0
	if size(filepath,1) > 1 || gui.retr('video_selection_done') == 1
		if strncmp(get(handles.multip03, 'visible'), 'on',2)
			if get(handles.zoomon,'Value')==1
				set(handles.zoomon,'Value',0);
				gui.zoomon_Callback(handles.zoomon)
			end
			if get(handles.panon,'Value')==1
				set(handles.panon,'Value',0);
				gui.panon_Callback(handles.panon)
			end
			xzoomlimit=gui.retr('xzoomlimit');
			yzoomlimit=gui.retr('yzoomlimit');
			preproc.preview_preprocess_Callback
			if isempty(xzoomlimit)==0
				set(gca,'xlim',xzoomlimit)
				set(gca,'ylim',yzoomlimit)
			end
		else
			gui.sliderdisp(gui.retr('pivlab_axis'))
		end
		selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
		if gui.retr('video_selection_done') == 0
			set(handles.filenamebox,'value',selected);
		else
			set(handles.filenamebox,'value',1);
		end
	end
end

