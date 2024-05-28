function sliderrange(reset)
filepath=gui.gui_retr('filepath');
handles=gui.gui_gethand;
if gui.gui_retr('video_selection_done') == 0
	if size(filepath,1)>2
		sliderstepcount=size(filepath,1)/2;
		set(handles.fileselector, 'enable', 'on');
		if reset==1
			set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
		else
			set (handles.fileselector, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
		end
	else
		sliderstepcount=1;
		set(handles.fileselector, 'enable', 'off');
		if reset==1
			set (handles.fileselector,'value',1, 'min', 1,'max',2,'sliderstep', [0.5 0.5]);
		else
			set (handles.fileselector, 'min', 1,'max',2,'sliderstep', [0.5 0.5]);
		end
	end
else % a video has been imported
	%video_frame_selection=retr('video_frame_selection');
	%sliderstepcount=numel(video_frame_selection)/2;
	%set(handles.fileselector, 'enable', 'on');
	%set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
	sliderstepcount=size(filepath,1)/2;
	set(handles.fileselector, 'enable', 'on');
	if reset==1
		set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
	else
		set (handles.fileselector, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
	end
end

