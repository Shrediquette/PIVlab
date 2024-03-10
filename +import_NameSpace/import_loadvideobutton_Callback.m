function import_loadvideobutton_Callback(~,~,~)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[gui_NameSpace.gui_retr('pathname') '\'];
else
	pathname=[gui_NameSpace.gui_retr('pathname') '/'];
end
handles=gui_NameSpace.gui_gethand;
gui_NameSpace.gui_displogo(0)
setappdata(hgui,'video_selection_done',0);
if gui_NameSpace.gui_retr('parallel')==1 %videos are not yet supported in parallel processing. But an opened parallel pool (that is not used) slows down video processing
	pivparpool('close')
	disp('Parallel video processing is not yet supported by PIVlab. Parallel pool was therefore closed.')
end
vid_import(pathname);
uiwait
if getappdata(hgui,'video_selection_done')
	gui_NameSpace.gui_put('expected_image_size',[])
	pathname = getappdata(hgui,'pathname');
	filename = getappdata(hgui,'filename');
	filepath = getappdata(hgui,'filepath');
	%save video file object in GUI
	gui_NameSpace.gui_put('video_reader_object',VideoReader(filepath{1}));
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui_NameSpace.gui_zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui_NameSpace.gui_panon_Callback(handles.zoomon)
	end
	gui_NameSpace.gui_put('xzoomlimit',[]);
	gui_NameSpace.gui_put('yzoomlimit',[]);
	gui_NameSpace.gui_sliderrange(1)
	set (handles.filenamebox, 'string', filename);
	gui_NameSpace.gui_put('bg_img_A',[]);
	gui_NameSpace.gui_put('bg_img_B',[]);
	gui_NameSpace.gui_put ('resultslist', []); %clears old results
	gui_NameSpace.gui_put ('derived',[]);
	gui_NameSpace.gui_put('displaywhat',1);%vectors
	gui_NameSpace.gui_put('ismean',[]);
	gui_NameSpace.gui_put('framemanualdeletion',[]);
	gui_NameSpace.gui_put('manualdeletion',[]);
	gui_NameSpace.gui_put('streamlinesX',[]);
	gui_NameSpace.gui_put('streamlinesY',[]);
	set(handles.fileselector, 'value',1);
	set(handles.minintens, 'string', 0);
	set(handles.maxintens, 'string', 1);
	%Clear all things
	validate_NameSpace.validate_clear_vel_limit_Callback %clear velocity limits
	roi_NameSpace.roi_clear_roi_Callback
	%clear_mask_Callback:
	gui_NameSpace.gui_put('masks_in_frame',[]);
	%reset zoom
	set(handles.panon,'Value',0);
	set(handles.zoomon,'Value',0);
	gui_NameSpace.gui_put('xzoomlimit', []);
	gui_NameSpace.gui_put('yzoomlimit', []);
	set(handles.filenamebox,'value',1);
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis')) %displays raw image when slider moves
	zoom reset
	gui_NameSpace.gui_put('sequencer',0);%time-resolved = only possibility for video
end
