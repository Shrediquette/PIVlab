function piv_DCC_and_DFT_analyze_all
ok=gui_NameSpace.gui_checksettings;
handles=gui_NameSpace.gui_gethand;
try
	warning off
	recycle('off');
	delete('cancel_piv');
	gui_NameSpace.gui_put('cancel',0);
	warning on
catch ME
	disp('There was an error deleting a temporary file.')
	disp('Please check if this solves your problem:')
	disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
	disp(ME)
end
if ok==1
	try
		if get(handles.update_display_checkbox,'Value')==1
			gui_NameSpace.gui_put('update_display',1);
		else
			gui_NameSpace.gui_put('update_display',0);
			%text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
		end
	catch
		gui_NameSpace.gui_put('update_display',1)
	end
	filepath=gui_NameSpace.gui_retr('filepath');
	filename=gui_NameSpace.gui_retr('filename');
	toggler=gui_NameSpace.gui_retr('toggler');
	resultslist=cell(0); %clear old results

	gui_NameSpace.gui_put('derived', [])
	gui_NameSpace.gui_toolsavailable(0,'Busy, please wait...');
	set (handles.cancelbutt, 'enable', 'on');

	ismean=gui_NameSpace.gui_retr('ismean');
	for i=size(ismean,1):-1:1 %remove averaged results
		if ismean(i,1)==1
			filepath(i*2,:)=[];
			filename(i*2,:)=[];

			filepath(i*2-1,:)=[];
			filename(i*2-1,:)=[];
		end
	end
	gui_NameSpace.gui_put('filepath',filepath);
	gui_NameSpace.gui_put('filename',filename);
	gui_NameSpace.gui_put('ismean',[]);
	masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
	if isempty(masks_in_frame)
		%masks_in_frame=cell(floor(size(filepath,1)/2),1);
		masks_in_frame=cell(1,floor(size(filepath,1)/2));
	end

	gui_NameSpace.gui_sliderrange(1)

	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));

	%Autolimit_Callback
	autolimit=get(handles.Autolimit, 'value');
	minintens=str2double(get(handles.minintens, 'string'));
	maxintens=str2double(get(handles.maxintens, 'string'));
	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=gui_NameSpace.gui_retr('roirect');

	interrogationarea=str2double(get(handles.intarea, 'string'));
	step=str2double(get(handles.step, 'string'));
	subpixfinder=get(handles.subpix,'value');

	int2=str2num(get(handles.edit50,'string'));
	int3=str2num(get(handles.edit51,'string'));
	int4=str2num(get(handles.edit52,'string'));
	mask_auto = get(handles.mask_auto_box,'value');
	[imdeform, repeat, do_pad] = piv_NameSpace.piv_CorrQuality;


	if gui_NameSpace.gui_retr('video_selection_done')==0
		num_frames_to_process = size(filepath,1);
	else
		video_frame_selection=gui_NameSpace.gui_retr('video_frame_selection');
		num_frames_to_process = numel(video_frame_selection);
	end

	if gui_NameSpace.gui_retr('parallel')==1 && gui_NameSpace.gui_retr('video_selection_done') == 1
		disp('Parallel processing of video files not yet supported.')
	end
	if gui_NameSpace.gui_retr('parallel')==1 && gui_NameSpace.gui_retr('video_selection_done') == 0
		%parallel toolbox available
		%drawnow; %#ok<*NBRAK>
		set(handles.progress, 'string' , ['Frame progress: 100%']);
		set(handles.overall, 'string' , ['Total progress: 0%']);
		drawnow; %#ok<*NBRAK>

		do_correlation_matrices=gui_NameSpace.gui_retr('do_correlation_matrices');
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		xlist=cell(0);
		ylist=cell(0);
		ulist=cell(0);
		vlist=cell(0);
		typelist=cell(0);
		corrlist=cell(0);
		correlation_matrices_list=cell(0);
		for i=1:2:num_frames_to_process
			k=(i+1)/2;
			slicedfilepath1{k}=filepath{i};
			slicedfilepath2{k}=filepath{i+1};
		end
		%set(handles.totaltime, 'String','Time elapsed: N/A');
		%xpos=size(image1,2)/2-40;
		info=text(60,50, 'Analyzing ...','color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 16, 'BackgroundColor', 'k', 'tag', 'annoyingthing');
		drawnow;
		calc_time_start=tic;
		hbar = pivprogress(size(slicedfilepath1,2),handles.overall);
		set(handles.totaltime,'String','');

		if get(handles.dcc,'Value')==1
			if get(handles.bg_subtract,'Value')==1
				bg_img_A = gui_NameSpace.gui_retr('bg_img_A');
				bg_img_B = gui_NameSpace.gui_retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
				bg_img_B=[];
				bg_sub=0;
			end

			masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
			if isempty(masks_in_frame)
				%masks_in_frame=cell(size(slicedfilepath1,2),1);
				masks_in_frame=cell(1,size(slicedfilepath1,2));
			end

			parfor i=1:size(slicedfilepath1,2)
				if exist('cancel_piv','file')
					close(hbar);
					continue
				end

				[~,~,ext] = fileparts(slicedfilepath1{i});
				if strcmp(ext,'.b16')
					currentimage1=f_readB16(slicedfilepath1{i});
					currentimage2=f_readB16(slicedfilepath2{i});

				else
					currentimage1=imread(slicedfilepath1{i});
					currentimage2=imread(slicedfilepath2{i});
				end
				if bg_sub==1
					if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
						currentimage1 = rgb2gray(currentimage1)-bg_img_A;
						currentimage2 = rgb2gray(currentimage2)-bg_img_B;
					else
						currentimage1 = currentimage1-bg_img_A;
						currentimage2 = currentimage2-bg_img_B;
					end
				end

				%get and save the image size (assuming that every image of a session has the same size)

				currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
				currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
				image1=currentimage1;
				image2=currentimage2;


				minintenst=minintens;
				maxintenst=maxintens;
				if autolimit == 1
					if toggler==0
						if size(image1,3)>1
							stretcher = stretchlim(rgb2gray(image1));
						else
							stretcher = stretchlim(image1);
						end
					else
						if size(image2,3)>1
							stretcher = stretchlim(rgb2gray(image2));
						else
							stretcher = stretchlim(image2);
						end
					end
					minintenst=stretcher(1);
					maxintenst=stretcher(2);
				end
				image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);


				if numel(masks_in_frame)< i
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{i};
				end

				converted_mask=mask_NameSpace.mask_convert_masks_to_binary(size(currentimage1(:,:,1)),mask_positions);

				[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect); %#ok<PFTUSW>
				xlist{i}=x;
				ylist{i}=y;
				ulist{i}=u;
				vlist{i}=v;
				typelist{i}=typevector;
				corrlist{i}=zeros(size(typevector)); %no correlation coefficient in DCC.
				correlation_matrices_list{i}=[];%no correlation matrix output for dcc
				hbar.iterate(1);
			end
		elseif get(handles.fftmulti,'Value')==1
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
			repeat_last_pass = get(handles.repeat_last,'Value');
			delta_diff_min = str2double(get(handles.edit52x,'String'));
			if get(handles.bg_subtract,'Value')==1
				bg_img_A = gui_NameSpace.gui_retr('bg_img_A');
				bg_img_B = gui_NameSpace.gui_retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
				bg_img_B=[];
				bg_sub=0;
			end
			masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
			if isempty(masks_in_frame)
				%masks_in_frame=cell(size(slicedfilepath1,2),1);
				masks_in_frame=cell(1,size(slicedfilepath1,2));
			end


			parfor i=1:size(slicedfilepath1,2)
				%------------------------
				if exist('cancel_piv','file')
					close(hbar);
					continue
				end

				[~,~,ext] = fileparts(slicedfilepath1{i});
				if strcmp(ext,'.b16')
					currentimage1=f_readB16(slicedfilepath1{i});
					currentimage2=f_readB16(slicedfilepath2{i});
				else
					currentimage1=imread(slicedfilepath1{i});
					currentimage2=imread(slicedfilepath2{i});
				end

				if numel(masks_in_frame)< i
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{i};
				end
				converted_mask=mask_NameSpace.mask_convert_masks_to_binary(size(currentimage1(:,:,1)),mask_positions);

				if bg_sub==1
					if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
						currentimage1 = rgb2gray(currentimage1)-bg_img_A;
						currentimage2 = rgb2gray(currentimage2)-bg_img_B;
					else
						currentimage1 = currentimage1-bg_img_A;
						currentimage2 = currentimage2-bg_img_B;
					end
				end

				%get and save the image size (assuming that every image of a session has the same size)
				currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
				currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
				image1=currentimage1;
				image2=currentimage2;

				minintenst=minintens;
				maxintenst=maxintens;
				if autolimit == 1
					if toggler==0
						if size(image1,3)>1
							stretcher = stretchlim(rgb2gray(image1));
						else
							stretcher = stretchlim(image1);
						end
					else
						if size(image2,3)>1
							stretcher = stretchlim(rgb2gray(image2));
						else
							stretcher = stretchlim(image2);
						end
					end
					minintenst=stretcher(1);
					maxintenst=stretcher(2);
				end
				image1 = PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				image2 = PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min); %#ok<PFTUSW>
				xlist{i}=x;
				ylist{i}=y;
				ulist{i}=u;
				vlist{i}=v;
				typelist{i}=typevector;
				corrlist{i}=correlation_map;
				correlation_matrices_list{i}=correlation_matrices;
				hbar.iterate(1);
			end
		end
		close(hbar);
		zeit=toc(calc_time_start);
		hrs=zeit/60^2;
		mins=(hrs-floor(hrs))*60;
		secs=(mins-floor(mins))*60;
		hrs=floor(hrs);
		mins=floor(mins);
		secs=floor(secs);
		if gui_NameSpace.gui_retr('cancel')==0 %dont output anything if cancelled
			for i=1:size(slicedfilepath1,2)
				resultslist{1,i}=xlist{i};
				resultslist{2,i}=ylist{i};
				resultslist{3,i}=ulist{i};
				resultslist{4,i}=vlist{i};
				resultslist{5,i}=typelist{i};
				resultslist{6,i}=[];
				resultslist{12,i}=corrlist{i};
			end
			gui_NameSpace.gui_put('resultslist',resultslist);
			gui_NameSpace.gui_put('subtr_u', 0);
			gui_NameSpace.gui_put('subtr_v', 0);
		end
		gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
		delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%']);
		set(handles.totaltime,'string', ['Time elapsed: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
	end
	%% serial (standard) calculation
	if gui_NameSpace.gui_retr('parallel')==0 ||  gui_NameSpace.gui_retr('video_selection_done') == 1
		set (handles.cancelbutt, 'enable', 'on');

		masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(floor((num_frames_to_process+1)/2),1);
			masks_in_frame=cell(1,floor((num_frames_to_process+1)/2));
		end

		for i=1:2:num_frames_to_process
			if i==1
				tic
			end
			cancel=gui_NameSpace.gui_retr('cancel');
			if isempty(cancel)==1 || cancel ~=1
				image1 = import_NameSpace.import_get_img(i);
				image2 = import_NameSpace.import_get_img(i+1);
				%if size(image1,3)>1
				%	image1=uint8(mean(image1,3));
				%	image2=uint8(mean(image2,3));
				%disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
				%end
				set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow; %#ok<*NBRAK>
				clahe=get(handles.clahe_enable,'value');
				highp=get(handles.enable_highpass,'value');
				%clip=get(handles.enable_clip,'value');
				intenscap=get(handles.enable_intenscap, 'value');
				clahesize=str2double(get(handles.clahe_size, 'string'));
				highpsize=str2double(get(handles.highp_size, 'string'));
				wienerwurst=get(handles.wienerwurst, 'value');
				wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
				do_correlation_matrices=gui_NameSpace.gui_retr('do_correlation_matrices');
				preproc_NameSpace.preproc_Autolimit_Callback
				minintens=str2double(get(handles.minintens, 'string'));
				maxintens=str2double(get(handles.maxintens, 'string'));
				%clipthresh=str2double(get(handles.clip_thresh, 'string'));
				roirect=gui_NameSpace.gui_retr('roirect');
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
				interrogationarea=str2double(get(handles.intarea, 'string'));
				step=str2double(get(handles.step, 'string'));
				subpixfinder=get(handles.subpix,'value');

				currentmask=floor((i+1)/2);

				if numel(masks_in_frame)< currentmask
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{currentmask};
				end

				converted_mask=mask_NameSpace.mask_convert_masks_to_binary(size(image1(:,:,1)),mask_positions);

				if get(handles.dcc,'Value')==1
					[x, y, u, v, typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect);
					correlation_matrices=[];%not available for DCC
				elseif get(handles.fftmulti,'Value')==1
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
					repeat_last_pass = get(handles.repeat_last,'Value');
					delta_diff_min = str2double(get(handles.edit52x,'String'));
					[imdeform, repeat, do_pad] = piv_NameSpace.piv_CorrQuality;
					[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
					%u=real(u)
					%v=real(v)
				end
				resultslist{1,(i+1)/2}=x;
				resultslist{2,(i+1)/2}=y;
				resultslist{3,(i+1)/2}=u;
				resultslist{4,(i+1)/2}=v;
				resultslist{5,(i+1)/2}=typevector;
				resultslist{6,(i+1)/2}=[];
				if get(handles.dcc,'Value')==1
					correlation_map=zeros(size(x));
				end
				correlation_matrices_list{(i+1)/2}=correlation_matrices;
				resultslist{12,(i+1)/2}=correlation_map;
				gui_NameSpace.gui_put('resultslist',resultslist);
				set(handles.fileselector, 'value', (i+1)/2);
				set(handles.progress, 'string' , ['Frame progress: 100%'])
				set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/num_frames_to_process*200) '%'])
				gui_NameSpace.gui_put('subtr_u', 0);
				gui_NameSpace.gui_put('subtr_v', 0);
				if gui_NameSpace.gui_retr('update_display')==0
				else
					gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
				end
				%xpos=size(image1,2)/2-40;
				%text(xpos,50, ['Analyzing... ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%' ],'color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 20, 'tag', 'annoyingthing')
				zeit=toc;
				done=(i+1)/2;
				tocome=(num_frames_to_process/2)-done;
				zeit=zeit/done*tocome;
				hrs=zeit/60^2;
				mins=(hrs-floor(hrs))*60;
				secs=(mins-floor(mins))*60;
				hrs=floor(hrs);
				mins=floor(mins);
				secs=floor(secs);
				set(handles.totaltime,'string', ['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
			end %cancel==0
		end

		delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
	end
	cancel=gui_NameSpace.gui_retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		try
			sound(audioread('finished.mp3'),44100);
		catch
		end
	end
	gui_NameSpace.gui_put('cancel',0);
	try
		warning off
		recycle('off');
		delete('cancel_piv')
		warning on
	catch ME
		disp('There was an error deleting a temporary file.')
		disp('Please check if this solves your problem:')
		disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
		disp(ME)
	end
	assignin('base','correlation_matrices',correlation_matrices_list);
end
gui_NameSpace.gui_toolsavailable(1);
gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
