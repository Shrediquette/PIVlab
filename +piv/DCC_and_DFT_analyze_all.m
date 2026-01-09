function DCC_and_DFT_analyze_all
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
	framenum=gui.retr('framenum');
	filename=gui.retr('filename');
	framepart = gui.retr ('framepart');

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
	masks_in_frame=gui.retr('masks_in_frame');
	if isempty(masks_in_frame)
		%masks_in_frame=cell(floor(size(filepath,1)/2),1);
		masks_in_frame=cell(1,floor(size(filepath,1)/2));
	end

	gui.sliderrange(1)

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
	roirect=gui.retr('roirect');

	interrogationarea=str2double(get(handles.intarea, 'string'));
	step=str2double(get(handles.step, 'string'));
	subpixfinder=get(handles.subpix,'value');

	int2=str2num(get(handles.edit50,'string'));
	int3=str2num(get(handles.edit51,'string'));
	int4=str2num(get(handles.edit52,'string'));
	mask_auto = get(handles.mask_auto_box,'value');
	[imdeform, repeat, do_pad] = piv.CorrQuality;


	if gui.retr('video_selection_done')==0
		num_frames_to_process = size(filepath,1);
	else
		video_frame_selection=gui.retr('video_frame_selection');
		num_frames_to_process = numel(video_frame_selection);
	end

	if gui.retr('parallel')==1 && gui.retr('video_selection_done') == 1
		disp('Parallel processing of video files not yet supported.')
	end
	if gui.retr('parallel')==1 && gui.retr('video_selection_done') == 0
		%parallel toolbox available
		%drawnow; %#ok<*NBRAK>
		set(handles.progress, 'string' , ['Frame progress: 100%']);
		set(handles.overall, 'string' , ['Total progress: 0%']);
		drawnow; %#ok<*NBRAK>

		do_correlation_matrices=gui.retr('do_correlation_matrices');
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
		if get(handles.algorithm_selection,'Value')==3 %dcc
			if get(handles.bg_subtract,'Value')>1
				bg_img_A = gui.retr('bg_img_A');
				bg_img_B = gui.retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
                bg_img_B=[];
                bg_sub=0;
            end

            masks_in_frame=gui.retr('masks_in_frame');
            if isempty(masks_in_frame)
                %masks_in_frame=cell(size(slicedfilepath1,2),1);
                masks_in_frame=cell(1,size(slicedfilepath1,2));
            end
            view_raw=handles.calib_viewtype.Value;
            if view_raw==1
                view='valid';
            elseif view_raw==2
                view='same';
            elseif view_raw==3
                view='full';
            end
            cam_use_calibration = gui.retr('cam_use_calibration');
            cam_use_rectification = gui.retr('cam_use_rectification');
            cameraParams=gui.retr('cameraParams');
            rectification_tform = gui.retr('rectification_tform');

            parfor i=1:size(slicedfilepath1,2)
                if exist(fullfile(userpath,'cancel_piv'),'file')
                    close(hbar);
                    continue
                end

                [~,~,ext] = fileparts(slicedfilepath1{i});
                if strcmp(ext,'.b16')
                    currentimage1=import.f_readB16(slicedfilepath1{i});
                    currentimage2=import.f_readB16(slicedfilepath2{i});
                    currentimage1 = preproc.cam_undistort(currentimage1,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                    currentimage2 = preproc.cam_undistort(currentimage2,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                else
                    currentimage1=import.imread_wrapper(slicedfilepath1{i},slicedframenum1(i),slicedframepart1(i,:))
                    currentimage2=import.imread_wrapper(slicedfilepath2{i},slicedframenum2(i),slicedframepart2(i,:))
                    currentimage1 = preproc.cam_undistort(currentimage1,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                    currentimage2 = preproc.cam_undistort(currentimage2,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
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

				stretcher_A=[]; %initialize for parfor loop
				stretcher_B=[];
				if autolimit == 1
					if size(image1,3)>1
						stretcher_A = stretchlim(rgb2gray(image1));
						stretcher_B = stretchlim(rgb2gray(image2));
					else
						stretcher_A = stretchlim(image1);
						stretcher_B = stretchlim(image2);
					end
				else
					stretcher_A(1)=minintens;
					stretcher_B(1)=minintens;
					stretcher_A(2)=maxintens;
					stretcher_B(2)=maxintens;
				end

				image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_A(1),stretcher_A(2));
				image2 = preproc.PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_B(1),stretcher_B(2));


				if numel(masks_in_frame)< i
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{i};
				end

				converted_mask=mask.convert_masks_to_binary(size(currentimage1(:,:,1)),mask_positions);

				[x, y, u, v, typevector] = piv.piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect); %#ok<PFTUSW>
				xlist{i}=x;
				ylist{i}=y;
				ulist{i}=u;
				vlist{i}=v;
				typelist{i}=typevector;
				corrlist{i}=zeros(size(typevector)); %no correlation coefficient in DCC.
				correlation_matrices_list{i}=[];%no correlation matrix output for dcc
				hbar.iterate(1);
			end
		elseif get(handles.algorithm_selection,'Value')==1
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
			if get(handles.bg_subtract,'Value')>1
				bg_img_A = gui.retr('bg_img_A');
				bg_img_B = gui.retr('bg_img_B');
				bg_sub=1;
			else
				bg_img_A=[];
				bg_img_B=[];
				bg_sub=0;
			end
			masks_in_frame=gui.retr('masks_in_frame');
			if isempty(masks_in_frame)
				%masks_in_frame=cell(size(slicedfilepath1,2),1);
				masks_in_frame=cell(1,size(slicedfilepath1,2));
            end
            view_raw=handles.calib_viewtype.Value;
            if view_raw==1
                view='valid';
            elseif view_raw==2
                view='same';
            elseif view_raw==3
                view='full';
            end
            cam_use_calibration = gui.retr('cam_use_calibration');
            cam_use_rectification = gui.retr('cam_use_rectification');
            cameraParams=gui.retr('cameraParams');
            rectification_tform = gui.retr('rectification_tform');

            parfor i=1:size(slicedfilepath1,2)
                %------------------------
                if exist(fullfile(userpath,'cancel_piv'),'file')
                    close(hbar);
                    continue
                end

                [~,~,ext] = fileparts(slicedfilepath1{i});
                if strcmp(ext,'.b16')
                    currentimage1=import.f_readB16(slicedfilepath1{i});
                    currentimage2=import.f_readB16(slicedfilepath2{i});
                    currentimage1 = preproc.cam_undistort(currentimage1,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                    currentimage2 = preproc.cam_undistort(currentimage2,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                else
                    currentimage1=import.imread_wrapper(slicedfilepath1{i},slicedframenum1(i),slicedframepart1(i,:));
                    currentimage2=import.imread_wrapper(slicedfilepath2{i},slicedframenum2(i),slicedframepart2(i,:));
                    if size(currentimage1,3)>3
                        currentimage1=currentimage1(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
                        currentimage2=currentimage2(:,:,1:3); %Chronos prototype has 4channels (all identical...?)
                    end
                    currentimage1 = preproc.cam_undistort(currentimage1,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                    currentimage2 = preproc.cam_undistort(currentimage2,'cubic',view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform);
                end

                if numel(masks_in_frame)< i
                    mask_positions=cell(0);
                else
                    mask_positions=masks_in_frame{i};
                end
                converted_mask=mask.convert_masks_to_binary(size(currentimage1(:,:,1)),mask_positions);

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

                stretcher_A=[]; %initialize for parfor loop
				stretcher_B=[];
				if autolimit == 1
					if size(image1,3)>1
						stretcher_A = stretchlim(rgb2gray(image1));
						stretcher_B = stretchlim(rgb2gray(image2));
					else
						stretcher_A = stretchlim(image1);
						stretcher_B = stretchlim(image2);
					end
				else
					stretcher_A(1)=minintens;
					stretcher_B(1)=minintens;
					stretcher_A(2)=maxintens;
					stretcher_B(2)=maxintens;
				end

				image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_A(1),stretcher_A(2));
				image2 = preproc.PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_B(1),stretcher_B(2));

				[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv.piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min); %#ok<PFTUSW>
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
	%% serial (standard) calculation
	if gui.retr('parallel')==0 ||  gui.retr('video_selection_done') == 1
		set (handles.cancelbutt, 'enable', 'on');

		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(floor((num_frames_to_process+1)/2),1);
			masks_in_frame=cell(1,floor((num_frames_to_process+1)/2));
		end

		for i=1:2:num_frames_to_process
			if i==1
				tic
			end
			cancel=gui.retr('cancel');
			if isempty(cancel)==1 || cancel ~=1
				image1 = import.get_img(i);
				image2 = import.get_img(i+1);
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
				do_correlation_matrices=gui.retr('do_correlation_matrices');
				preproc.Autolimit_Callback
				minintens=str2double(get(handles.minintens, 'string'));
				maxintens=str2double(get(handles.maxintens, 'string'));
				%clipthresh=str2double(get(handles.clip_thresh, 'string'));
				roirect=gui.retr('roirect');

				stretcher_A=[]; %initialize for parfor loop
				stretcher_B=[];
				if autolimit == 1
					if size(image1,3)>1
						stretcher_A = stretchlim(rgb2gray(image1));
						stretcher_B = stretchlim(rgb2gray(image2));
					else
						stretcher_A = stretchlim(image1);
						stretcher_B = stretchlim(image2);
					end
				else
					stretcher_A(1)=minintens;
					stretcher_B(1)=minintens;
					stretcher_A(2)=maxintens;
					stretcher_B(2)=maxintens;
				end

				image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_A(1),stretcher_A(2));
				image2 = preproc.PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,stretcher_B(1),stretcher_B(2));
							
				interrogationarea=str2double(get(handles.intarea, 'string'));
				step=str2double(get(handles.step, 'string'));
				subpixfinder=get(handles.subpix,'value');

				currentmask=floor((i+1)/2);

				if numel(masks_in_frame)< currentmask
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{currentmask};
				end

				converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);

				if get(handles.algorithm_selection,'Value')==3 %dcc
					[x, y, u, v, typevector] = piv.piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect);
					correlation_matrices=[];%not available for DCC
				elseif get(handles.algorithm_selection,'Value')==1
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
					[imdeform, repeat, do_pad] = piv.CorrQuality;
					[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv.piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
					%u=real(u)
					%v=real(v)
				end
				resultslist{1,(i+1)/2}=x;
				resultslist{2,(i+1)/2}=y;
				resultslist{3,(i+1)/2}=u;
				resultslist{4,(i+1)/2}=v;
				resultslist{5,(i+1)/2}=typevector;
				resultslist{6,(i+1)/2}=[];
				if get(handles.algorithm_selection,'Value')==3 %dcc
					correlation_map=zeros(size(x));
				end
				correlation_matrices_list{(i+1)/2}=correlation_matrices;
				resultslist{12,(i+1)/2}=correlation_map;
				gui.put('resultslist',resultslist);
				set(handles.fileselector, 'value', (i+1)/2);
				%set(handles.progress, 'string' , ['Frame progress: 100%'])
				set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/num_frames_to_process*200) '%'])
				gui.update_progress((i+1)/2/num_frames_to_process*200)
				gui.put('subtr_u', 0);
				gui.put('subtr_v', 0);
				if gui.retr('update_display')==0
				else
					gui.sliderdisp(gui.retr('pivlab_axis'))
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
		gui.update_progress(0)
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(toc*10)/10) ' s']);
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
	assignin('base','correlation_matrices',correlation_matrices_list);
end
gui.toolsavailable(1);
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))

