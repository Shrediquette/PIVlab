function preproc_preview_preprocess_Callback(~, ~, ~)
filepath=gui_NameSpace.gui_retr('filepath');
if size(filepath,1) >1 || gui_NameSpace.gui_retr('video_selection_done') == 1
	handles=gui_NameSpace.gui_gethand;
	toggler=gui_NameSpace.gui_retr('toggler');
	filepath=gui_NameSpace.gui_retr('filepath');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	if gui_NameSpace.gui_retr('video_selection_done') == 0 && gui_NameSpace.gui_retr('parallel')==1% this is not nice, duplicated functions, one for parallel and one for video....
		preproc_NameSpace.preproc_generate_BG_img_parallel
	else
		preproc_NameSpace.preproc_generate_BG_img
	end
	[img,~]=import_NameSpace.import_get_img(selected);
	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	preproc_NameSpace.preproc_Autolimit_Callback
	minintens=str2double(get(handles.minintens, 'string'));
	maxintens=str2double(get(handles.maxintens, 'string'));

	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=gui_NameSpace.gui_retr('roirect');
	if size (roirect,2)<4
		roirect=[1,1,size(img,2)-1,size(img,1)-1];
	end
	out = PIVlab_preproc (img,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
	pivlab_axis=gui_NameSpace.gui_retr('pivlab_axis');
	image(out, 'parent',pivlab_axis, 'cdatamapping', 'scaled');
	colormap('gray');
	axis image;
	set(gca,'ytick',[]);
	set(gca,'xtick',[]);
	roirect=gui_NameSpace.gui_retr('roirect');
	if size(roirect,2)>1
		roi_NameSpace.roi_dispStaticROI(gui_NameSpace.gui_retr('pivlab_axis'))
	end
	currentframe=2*floor(get(handles.fileselector, 'value'))-1;
end
