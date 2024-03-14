function piv_AnalyzeSingle_Callback(~, ~, ~)
handles=gui.gui_gethand;
ok=gui.gui_checksettings;
if ok==1
	resultslist=gui.gui_retr('resultslist');
	set(handles.progress, 'string' , ['Frame progress: 0%']);
	set(handles.Settings_Apply_current, 'string' , ['Please wait...']);
	gui.gui_toolsavailable(0,'Busy, please wait...');drawnow;
	handles=gui.gui_gethand;
	filepath=gui.gui_retr('filepath');
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	ismean=gui.gui_retr('ismean');
	if size(ismean,1)>=(selected+1)/2
		if ismean((selected+1)/2,1) ==1
			currentwasmean=1;
		else
			currentwasmean=0;
		end
	else
		currentwasmean=0;
	end
	if currentwasmean==0
		tic;
		[image1,~]=import.import_get_img(selected);
		[image2,~]=import.import_get_img(selected+1);
		%if size(image1,3)>1
		%image1=uint8(mean(image1,3));
		%image2=uint8(mean(image2,3));
		%disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
		%end
		clahe=get(handles.clahe_enable,'value');
		highp=get(handles.enable_highpass,'value');
		%clip=get(handles.enable_clip,'value');
		intenscap=get(handles.enable_intenscap, 'value');
		clahesize=str2double(get(handles.clahe_size, 'string'));
		highpsize=str2double(get(handles.highp_size, 'string'));
		wienerwurst=get(handles.wienerwurst, 'value');
		wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
		preproc.preproc_Autolimit_Callback
		minintens=str2double(get(handles.minintens, 'string'));
		maxintens=str2double(get(handles.maxintens, 'string'));
		%clipthresh=str2double(get(handles.clip_thresh, 'string'));
		roirect=gui.gui_retr('roirect');
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image1,3)>1
				stretcher = stretchlim(rgb2gray(image1));
			else
				stretcher = stretchlim(image1);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end
		image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image2,3)>1
				stretcher = stretchlim(rgb2gray(image2));
			else
				stretcher = stretchlim(image2);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end

		image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

		current_mask_nr=floor(get(handles.fileselector, 'value'));
		masks_in_frame=gui.gui_retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(current_mask_nr,1);
			masks_in_frame=cell(1,current_mask_nr);
		end
		if numel(masks_in_frame)<current_mask_nr
			mask_positions=cell(0);
		else
			mask_positions=masks_in_frame{current_mask_nr};
		end
		converted_mask=mask.mask_convert_masks_to_binary(size(image1(:,:,1)),mask_positions);

		interrogationarea=str2double(get(handles.intarea, 'string'));
		step=str2double(get(handles.step, 'string'));
		subpixfinder=get(handles.subpix,'value');
		do_correlation_matrices=gui.gui_retr('do_correlation_matrices');
		if get(handles.dcc,'Value')==1
			[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect);
			correlation_map=zeros(size(u)); %nor correlation map available with DCC
			correlation_matrices=[];
		elseif get(handles.fftmulti,'Value')==1 || get(handles.ensemble,'Value')==1
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
			[imdeform, repeat, do_pad] = piv.piv_CorrQuality;
			mask_auto = get(handles.mask_auto_box,'value');
			repeat_last_pass = get(handles.repeat_last,'Value');
			delta_diff_min = str2double(get(handles.edit52x,'String'));
			if get(handles.fftmulti,'Value')==1
				try
					[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
				catch ME
					disp(getReport(ME))
					gui.gui_toolsavailable(1);
				end
			end

		end
		gui.gui_toolsavailable(1);
		resultslist{1,(selected+1)/2}=x;
		resultslist{2,(selected+1)/2}=y;
		resultslist{3,(selected+1)/2}=u;
		resultslist{4,(selected+1)/2}=v;
		resultslist{5,(selected+1)/2}=typevector;
		resultslist{6,(selected+1)/2}=[];
		%clear previous interpolation results
		resultslist{7, (selected+1)/2} = [];
		resultslist{8, (selected+1)/2} = [];
		resultslist{9, (selected+1)/2} = [];
		resultslist{10, (selected+1)/2} = [];
		resultslist{11, (selected+1)/2} = [];
		resultslist{12,(selected+1)/2}=correlation_map;
		gui.gui_put('derived', [])
		gui.gui_put('resultslist',resultslist);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		set(handles.overall, 'string' , ['Total progress: 100%'])
		set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
		time1frame=toc;
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(time1frame*100)/100) ' s']);
		set(handles.messagetext, 'String','');
		gui.gui_put('subtr_u', 0);
		gui.gui_put('subtr_v', 0);
		assignin('base','correlation_matrices',correlation_matrices);
		gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
	end

end

