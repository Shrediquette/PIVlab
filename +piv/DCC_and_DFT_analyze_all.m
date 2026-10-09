function DCC_and_DFT_analyze_all
ok=gui.checksettings;
handles=gui.gethand;
try
	recycle('off');
	if isfile(fullfile(userpath,'cancel_piv'))
		delete(fullfile(userpath,'cancel_piv'));
	end
	gui.put('cancel',0);
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

		slicedfilepath1=cell(0);
		xlist=cell(0);
		ylist=cell(0);
		ulist=cell(0);
		vlist=cell(0);
		typelist=cell(0);
		corrlist=cell(0);
		u2list=cell(0);
		v2list=cell(0);
		umaplist=cell(0);
		%correlation_matrices_list=cell(0);
		for i=1:2:num_frames_to_process
			k=(i+1)/2;
			slicedfilepath1{k}=filepath{i};
		end
		%set(handles.totaltime, 'String','Time elapsed: N/A');
		%xpos=size(image1,2)/2-40;
		info=text(60,50, 'Analyzing ...','color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 16, 'BackgroundColor', 'k', 'tag', 'annoyingthing');
		drawnow;
		calc_time_start=tic;
		hbar = gui.pivprogress(size(slicedfilepath1,2),handles.overall);
		set(handles.totaltime,'String','');
		% the per-pair work (reading, pre-processing, PIV) is shared with the command-line API (pivlab.analyze)
		s = piv.settings_from_gui(handles);
		if get(handles.bg_subtract,'Value')>1
			bg = struct('A',gui.retr('bg_img_A'),'B',gui.retr('bg_img_B'));
		else
			bg = [];
		end
		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			masks_in_frame=cell(1,size(slicedfilepath1,2));
		end
		cam = import.cam_settings(FromGUI=true);
		src = struct('filepath',{filepath},'framenum',framenum,'framepart',framepart);
		parfor i=1:size(slicedfilepath1,2)
			if exist(fullfile(userpath,'cancel_piv'),'file')
				close(hbar);
				continue
			end
			image1 = import.read_frame(src, 2*i-1, cam, bg);
			image2 = import.read_frame(src, 2*i, cam, bg);
			if numel(masks_in_frame)< i
				mask_positions=cell(0);
			else
				mask_positions=masks_in_frame{i};
			end
			r = piv.analyze_pair(image1, image2, mask_positions, s);
			xlist{i}=r.x;
			ylist{i}=r.y;
			ulist{i}=r.u;
			vlist{i}=r.v;
			typelist{i}=r.typevector;
			corrlist{i}=r.correlation_map;
			u2list{i}=r.u2;
			v2list{i}=r.v2;
			umaplist{i}=r.umap;
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
				resultslist{13,i}=u2list{i};
				resultslist{14,i}=v2list{i};
				resultslist{15,i}=umaplist{i};
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
				set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow; %#ok<*NBRAK>
				preproc.Autolimit_Callback %updates the displayed intensity limits
				% pre-processing and PIV are shared with the command-line API (pivlab.analyze)
				s = piv.settings_from_gui(handles);
				currentmask=floor((i+1)/2);
				if numel(masks_in_frame)< currentmask
					mask_positions=cell(0);
				else
					mask_positions=masks_in_frame{currentmask};
				end
				r = piv.analyze_pair(image1, image2, mask_positions, s);
				x=r.x; y=r.y; u=r.u; v=r.v; typevector=r.typevector;
				correlation_map=r.correlation_map; u2=r.u2; v2=r.v2; umap=r.umap;
				resultslist{1,(i+1)/2}=x;
				resultslist{2,(i+1)/2}=y;
				resultslist{3,(i+1)/2}=u;
				resultslist{4,(i+1)/2}=v;
				resultslist{5,(i+1)/2}=typevector;
				resultslist{6,(i+1)/2}=[];
				if get(handles.algorithm_selection,'Value')==3 %dcc
					correlation_map=zeros(size(x));
				end
				%correlation_matrices_list{(i+1)/2}=correlation_matrices;
				resultslist{12,(i+1)/2}=correlation_map;
				resultslist{13,(i+1)/2}=u2;
				resultslist{14,(i+1)/2}=v2;
				resultslist{15,(i+1)/2}=umap;
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
		recycle('off');
		if isfile(fullfile(userpath,'cancel_piv'))
			delete(fullfile(userpath,'cancel_piv'))
		end
	catch ME
		disp('There was an error deleting a temporary file.')
		disp('Please check if this solves your problem:')
		disp('https://groups.google.com/g/PIVlab/c/2O2EXgGg6Uc')
		disp(ME)
	end
	%assignin('base','correlation_matrices',correlation_matrices_list);
end
gui.toolsavailable(1);
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))
