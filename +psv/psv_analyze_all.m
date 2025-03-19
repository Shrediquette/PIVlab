function psv_analyze_all
ok=gui.checksettings;
handles=gui.gethand;
try
	warning off
	recycle('off');
	delete(fullfile(userpath,'cancel_piv'));
	gui.put('cancel',0);
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
			gui.put('update_display',1);
		else
			gui.put('update_display',0);
			%text(50,50,'Please wait...','color','r','fontsize',14, 'BackgroundColor', 'k','tag','hint');
		end
	catch
		gui.put('update_display',1)
	end
	filepath=gui.retr('filepath');
	filename=gui.retr('filename');
	toggler=gui.retr('toggler');
	resultslist=cell(0); %clear old results

	gui.put('derived', [])
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
	if gui.retr('video_selection_done')==0
		num_frames_to_process = size(filepath,1);
	else
		video_frame_selection=gui.retr('video_frame_selection');
		num_frames_to_process = numel(video_frame_selection);
	end

	if gui.retr('parallel')==1 && gui.retr('video_selection_done') == 1
		disp('Parallel processing of video files not yet supported.')
	end
	set (handles.cancelbutt, 'enable', 'on');
	masks_in_frame=gui.retr('masks_in_frame');
	if isempty(masks_in_frame)
		masks_in_frame=cell(1,floor((num_frames_to_process+1)/2));
	end


	%% pre-processing settings
	clahe=get(handles.clahe_enable,'value');
	highp=get(handles.enable_highpass,'value');
	%clip=get(handles.enable_clip,'value');
	intenscap=get(handles.enable_intenscap, 'value');
	clahesize=str2double(get(handles.clahe_size, 'string'));
	highpsize=str2double(get(handles.highp_size, 'string'));
	wienerwurst=get(handles.wienerwurst, 'value');
	wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
	do_correlation_matrices=gui.retr('do_correlation_matrices');
	preproc.Autolimit_Callback
	minintens=str2double(get(handles.minintens, 'string'));
	maxintens=str2double(get(handles.maxintens, 'string'));
	%clipthresh=str2double(get(handles.clip_thresh, 'string'));
	roirect=gui.retr('roirect');

	filepath=gui.retr('filepath');
	framenum=gui.retr('framenum');
	filename=gui.retr('filename');
	framepart = gui.retr ('framepart');

	%% PSV specific settings from GUI:

	binsize=str2double(get(handles.psv_binsize,'String'));

	%% serial (standard) calculation

	if gui.retr('parallel')==0 ||  gui.retr('video_selection_done') == 1
		tempImg = import.get_img(1);
		if isempty(roirect)
			roirect = [1,1,size(tempImg,2)-1,size(tempImg,1)-1];
		end
		for i=1:2:num_frames_to_process
			if i==1
				tic
			end
			cancel=gui.retr('cancel');
			if isempty(cancel)==1 || cancel ~=1
				image1 = import.get_img(i);

				set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow; %#ok<*NBRAK>

				image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
				if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
					if size(image1,3)>1
						stretcher = stretchlim(rgb2gray(image1));
					else
						stretcher = stretchlim(image1);
					end
					minintens = stretcher(1);
					maxintens = stretcher(2);
				end
				currentmask=floor((i+1)/2);

				if numel(masks_in_frame)< currentmask
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{currentmask};
				end

				converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);

				%% PSV calculation goes here
				img_BW = imbinarize(image1, str2double(get(handles.psv_threshold,'String')));

				[x,y,u,v,typevector] = psv.psv_code(img_BW, binsize,roirect,converted_mask);

				correlation_map=zeros(size(x));
				correlation_matrices=[];

				resultslist{1,(i+1)/2}=x;
				resultslist{2,(i+1)/2}=y;
				resultslist{3,(i+1)/2}=u;
				resultslist{4,(i+1)/2}=v;
				resultslist{5,(i+1)/2}=typevector;
				resultslist{6,(i+1)/2}=[];

				correlation_matrices_list{(i+1)/2}=correlation_matrices;
				resultslist{12,(i+1)/2}=correlation_map;
				gui.put('resultslist',resultslist);
				set(handles.fileselector, 'value', (i+1)/2);
				set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/num_frames_to_process*200) '%'])
				gui.update_progress((i+1)/2/num_frames_to_process*200)
				gui.put('subtr_u', 0);
				gui.put('subtr_v', 0);
				if gui.retr('update_display')==0
				else
					gui.sliderdisp(gui.retr('pivlab_axis'))
				end
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
		gui.update_progress(0)
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
	end

	if gui.retr('parallel')==1 && gui.retr('video_selection_done') == 0
		set(handles.progress, 'string' , ['Frame progress: 100%']);
		set(handles.overall, 'string' , ['Total progress: 0%']);
		drawnow; %#ok<*NBRAK>
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		slicedframenum1=[];
		slicedframenum2=[];
		slicedframepart1=[];
		slicedframepart2=[];
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
			slicedframenum1(k)=framenum(i);
			slicedframenum2(k)=framenum(i+1);
			slicedframepart1(k,:)=framepart(i,:);
			slicedframepart2(k,:)=framepart(i+1,:);
		end
		%set(handles.totaltime, 'String','Time elapsed: N/A');
		%xpos=size(image1,2)/2-40;
		info=text(60,50, 'Analyzing ...','color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 16, 'BackgroundColor', 'k', 'tag', 'annoyingthing');
		drawnow;
		calc_time_start=tic;
		hbar = gui.pivprogress(size(slicedfilepath1,2),handles.overall);
		set(handles.totaltime,'String','');
		autolimit=get(handles.Autolimit, 'value');
		minintens=str2double(get(handles.minintens, 'string'));
		maxintens=str2double(get(handles.maxintens, 'string'));
		%clipthresh=str2double(get(handles.clip_thresh, 'string'));
		roirect=gui.retr('roirect');
		if get(handles.bg_subtract,'Value')==1
			bg_img_A = gui.retr('bg_img_A');

			bg_sub=1;
		else
			bg_img_A=[];

			bg_sub=0;
		end

		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(size(slicedfilepath1,2),1);
			masks_in_frame=cell(1,size(slicedfilepath1,2));
		end

		parfor i=1:size(slicedfilepath1,2)
			if exist(fullfile(userpath,'cancel_piv'),'file')
				close(hbar);
				continue
			end
			[~,~,ext] = fileparts(slicedfilepath1{i});
			if strcmp(ext,'.b16')
				currentimage1=import.f_readB16(slicedfilepath1{i});
			else
				currentimage1=import.imread_wrapper(slicedfilepath1{i},slicedframenum1(i),slicedframepart1(i,:))
			end
			if bg_sub==1
				if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
					currentimage1 = rgb2gray(currentimage1)-bg_img_A;

				else
					currentimage1 = currentimage1-bg_img_A;
				end
			end
			%get and save the image size (assuming that every image of a session has the same size)
			currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
			image1=currentimage1;
			minintenst=minintens;
			maxintenst=maxintens;
			if autolimit == 1
				if size(image1,3)>1
					stretcher = stretchlim(rgb2gray(image1));
				else
					stretcher = stretchlim(image1);
				end

				minintenst=stretcher(1);
				maxintenst=stretcher(2);
			end
			image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
			if numel(masks_in_frame)< i
				mask_positions=cell(0);
			else
				mask_positions=masks_in_frame{i};
			end
			converted_mask=mask.convert_masks_to_binary(size(currentimage1(:,:,1)),mask_positions);
			img_BW = imbinarize(image1, str2double(get(handles.psv_threshold,'String')));
			[x,y,u,v,typevector] = psv.psv_code(img_BW, binsize,roirect,converted_mask);
			xlist{i}=x;
			ylist{i}=y;
			ulist{i}=u;
			vlist{i}=v;
			typelist{i}=typevector;
			corrlist{i}=zeros(size(typevector)); %no correlation coefficient in DCC.
			correlation_matrices_list{i}=[];%no correlation matrix output for dcc
			hbar.iterate(1);
		end
		close(hbar);
		zeit=toc(calc_time_start);
		hrs=zeit/60^2;
		mins=(hrs-floor(hrs))*60;
		secs=(mins-floor(mins))*60;
		hrs=floor(hrs);
		mins=floor(mins);
		secs=floor(secs);
		if gui.retr('cancel')==0 %dont output anything if cancelled
			for i=1:size(slicedfilepath1,2)
				resultslist{1,i}=xlist{i};
				resultslist{2,i}=ylist{i};
				resultslist{3,i}=ulist{i};
				resultslist{4,i}=vlist{i};
				resultslist{5,i}=typelist{i};
				resultslist{6,i}=[];
				resultslist{12,i}=corrlist{i};
			end
			gui.put('resultslist',resultslist);
			gui.put('subtr_u', 0);
			gui.put('subtr_v', 0);
		end
		gui.sliderdisp(gui.retr('pivlab_axis'))
		delete(findobj('tag', 'annoyingthing'));
		set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%']);
		set(handles.totaltime,'string', ['Time elapsed: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
	end
	cancel=gui.retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		try
			sound(audioread(fullfile('+misc','finished.mp3')),44100);
		catch
		end
	end
	gui.put('cancel',0);
	try
		warning off
		recycle('off');
		delete(fullfile(userpath,'cancel_piv'))
		warning on
	catch ME
		disp('There was an error deleting a temporary file.')
		disp('Please check if this solves your problem:')
		disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
		disp(ME)
	end
end
gui.toolsavailable(1);
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))