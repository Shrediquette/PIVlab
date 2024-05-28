function loadvideobutton_Callback(~,~,~)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[gui.retr('pathname') '\'];
else
	pathname=[gui.retr('pathname') '/'];
end
handles=gui.gethand;
gui.displogo(0)
setappdata(hgui,'video_selection_done',0);
if gui.retr('parallel')==1 %videos are not yet supported in parallel processing. But an opened parallel pool (that is not used) slows down video processing
	pivparpool('close')
	disp('Parallel video processing is not yet supported by PIVlab. Parallel pool was therefore closed.')
end
vid_import(pathname);
uiwait
if getappdata(hgui,'video_selection_done')
	gui.put('expected_image_size',[])
	pathname = getappdata(hgui,'pathname');
	filename = getappdata(hgui,'filename');
	filepath = getappdata(hgui,'filepath');
	%save video file object in GUI
	gui.put('video_reader_object',VideoReader(filepath{1}));
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui.zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui.panon_Callback(handles.zoomon)
	end
	gui.put('xzoomlimit',[]);
	gui.put('yzoomlimit',[]);
	gui.sliderrange(1)
	set (handles.filenamebox, 'string', filename);
	gui.put('bg_img_A',[]);
	gui.put('bg_img_B',[]);
	gui.put ('resultslist', []); %clears old results
	gui.put ('derived',[]);
	gui.put('displaywhat',1);%vectors
	gui.put('ismean',[]);
	gui.put('framemanualdeletion',[]);
	gui.put('manualdeletion',[]);
	gui.put('streamlinesX',[]);
	gui.put('streamlinesY',[]);
	set(handles.fileselector, 'value',1);
	set(handles.minintens, 'string', 0);
	set(handles.maxintens, 'string', 1);
	%Clear all things
	validate.clear_vel_limit_Callback %clear velocity limits
	roi.clear_roi_Callback
	%clear_mask_Callback:
	gui.put('masks_in_frame',[]);
	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	gui.put('xzoomlimit', []);
	gui.put('yzoomlimit', []);
	set(handles.filenamebox,'value',1);
	gui.sliderdisp(gui.retr('pivlab_axis')) %displays raw image when slider moves
	zoom reset
	gui.put('sequencer',0);%time-resolved = only possibility for video
end

