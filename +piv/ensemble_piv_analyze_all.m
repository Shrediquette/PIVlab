function ensemble_piv_analyze_all
handles=gui.gethand;
try
	if get(handles.update_display_checkbox,'Value')==1
		gui.put('update_display',1);
	else
		gui.put('update_display',0);
		%text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
	end
catch
	gui.put('update_display',1)
end
gui.put('cancel',0);
ok=gui.checksettings;
if ok==1
	filepath=gui.retr('filepath');
	framenum=gui.retr('framenum');
	framepart=gui.retr('framepart');
	filename=gui.retr('filename');
	resultslist=cell(0); %clear old results
	gui.toolsavailable(0,'Busy, please wait...');
	set (handles.cancelbutt, 'enable', 'on');
	ismean=gui.retr('ismean');

	for i=size(ismean,1):-1:1 %remove averaged results
		if ismean(i,1)==1
			filepath(i*2,:)=[];
			filename(i*2,:)=[];
			filepath(i*2-1,:)=[];
			filename(i*2-1,:)=[];
		end
	end
	gui.put('filepath',filepath);
	gui.put('filename',filename);
	gui.put('ismean',[]);
	gui.sliderrange(1)
	%% get all parameters for preprocessing
	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	preproc.Autolimit_Callback
	minintens1=str2double(get(handles.minintens, 'string'));
	maxintens1=str2double(get(handles.maxintens, 'string'));
	minintens2=str2double(get(handles.minintens, 'string'));
	maxintens2=str2double(get(handles.maxintens, 'string'));
	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=gui.retr('roirect');
	autolimit = get(handles.Autolimit, 'value');



	interrogationarea=str2double(get(handles.intarea, 'string'));
	step=str2double(get(handles.step, 'string'));
	subpixfinder=get(handles.subpix,'value');
	passes=1;
	if get(handles.checkbox26,'value')==1
		passes=2;
	end
	if get(handles.checkbox27,'value')==1
		passes=3;
	end
	if get(handles.checkbox28,'value')==1
		passes=4;
	end
	int2=str2num(get(handles.edit50,'string'));
	int3=str2num(get(handles.edit51,'string'));
	int4=str2num(get(handles.edit52,'string'));
	mask_auto = get(handles.mask_auto_box,'value');
	[imdeform, repeat, do_pad] = piv.CorrQuality;
	bg_img_A = gui.retr('bg_img_A'); %contains bg image, or is empty array
	bg_img_B = gui.retr('bg_img_B');
	%übergeben: Video frame selection

	%ensemble correlation ist anders... Hier müsste für alle frames bereits eine pixelmaske berechnet und übergeben werden.
	[tmp,~]=import.get_img(1);

	masks_in_frame=gui.retr('masks_in_frame');
	if isempty(masks_in_frame)
		%masks_in_frame=cell(floor(size(filepath,1)/2),1);
		masks_in_frame=cell(1,floor(size(filepath,1)/2));
	end
	converted_mask=cell(floor(size(filepath,1)/2),1);
	for ii=1:floor(size(filepath,1)/2)
		if numel(masks_in_frame) < ii
			masks_in_frame{ii}=cell(0);
		end
		mask_positions=masks_in_frame{ii};
		converted_mask{ii}=mask.convert_masks_to_binary(size(tmp(:,:,1)),mask_positions);
	end

	if gui.retr('video_selection_done') == 0
		video_frame_selection=[];
		[x, y, u, v, typevector,correlation_map] = piv.piv_FFTensemble (autolimit, filepath,framenum,framepart,video_frame_selection,bg_img_A,bg_img_B,clahe,highp,intenscap,clahesize,highpsize,wienerwurst,wienerwurstsize,roirect,converted_mask,interrogationarea,step,subpixfinder,passes,int2,int3,int4,mask_auto,imdeform,repeat,do_pad);
	else
		video_frame_selection=gui.retr('video_frame_selection');
		video_reader_object = gui.retr('video_reader_object');
		[x, y, u, v, typevector,correlation_map] = piv.piv_FFTensemble (autolimit, video_reader_object ,video_frame_selection,bg_img_A,bg_img_B,clahe,highp,intenscap,clahesize,highpsize,wienerwurst,wienerwurstsize,roirect,converted_mask,interrogationarea,step,subpixfinder,passes,int2,int3,int4,mask_auto,imdeform,repeat,do_pad);
	end

	cancel = gui.retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		%Fill all frames with the same result
		%{
        for filler=1:size(filepath,1)/2
            resultslist{1,filler}=x;
            resultslist{2,filler}=y;
            resultslist{3,filler}=u;
            resultslist{4,filler}=v;
            resultslist{5,filler}=typevector;
            resultslist{6,filler}=[];
        end
		%}

		%fill only first frame with results
		resultslist{1,1}=x;
		resultslist{2,1}=y;
		resultslist{3,1}=u;
		resultslist{4,1}=v;
		resultslist{5,1}=typevector;
		resultslist{6,1}=[];
		resultslist{12,1}=correlation_map;

		gui.put('resultslist',resultslist);
		set(handles.fileselector, 'value', 1);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		%set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%'])
		gui.update_progress(0)
		gui.put('subtr_u', 0);
		gui.put('subtr_v', 0);
		gui.sliderdisp(gui.retr('pivlab_axis'))
		%delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
		try
			sound(audioread(fullfile('+misc','finished.mp3')),44100);
		catch
		end
	else %user pressed cancel, no results
		if verLessThan('matlab','8.4')
			delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
		else
			delete (findobj(getappdata(0,'hgui'),'type', 'quiver'))
		end
		%delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String','Time left: N/A');
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		gui.update_progress(0)
		gui.sliderdisp(gui.retr('pivlab_axis'))
	end

	gui.put('cancel',0);
	gui.toolsavailable(1);
end

