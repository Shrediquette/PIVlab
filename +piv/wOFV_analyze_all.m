function wOFV_analyze_all
ok=gui.checksettings;
handles=gui.gethand;
try
	warning off
	recycle('off');
	delete('cancel_piv');
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

	%% serial (standard) calculation
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


	%% wOFV specific settings from GUI:
    etaUnScaled = str2double(get(handles.ofv_eta,'string'));
    PydLev = str2double(handles.ofv_pyramid_levels.String{handles.ofv_pyramid_levels.Value});
    
    %scaling eta from [0,100] to [1e-5,1e5]
    eta = 10^(etaUnScaled*0.1 - 5);
    
    if strcmp(handles.ofv_median.String{handles.ofv_median.Value},'Off')
        MedFiltFlag = false;
        MedFiltSize = [3,3];

    else
        MedFiltFlag = true;
        MedFiltSize = [str2double(handles.ofv_median.String{handles.ofv_median.Value}(1)),str2double(handles.ofv_median.String{handles.ofv_median.Value}(3))];
    end
    
    %load the filter matrices (assumes all the images are of the same size to compute the patch size)
    if strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Off')
        tempImg = import.get_img(1);
        tempImg = tempImg(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
        PatchSize = 2^floor(log2(min(size(tempImg))));
        Fmats = getFmatPyramid(PatchSize,PydLev);
        vartheta = ones(size(tempImg));
    elseif strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Default')
        tempImg = import.get_img(1);
        tempImg = tempImg(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
        PatchSize = 2^floor(log2(min(size(tempImg))));
        Fmats = getFmatPyramid(PatchSize,PydLev);
        vartheta = ones(size(tempImg));
    else
        tempImg = import.get_img(1);
        tempImg = tempImg(roirect(2):roirect(2)+roirect(4)-1,roirect(1):roirect(1)+roirect(3)-1);
        PatchSize = str2double(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value});
        Fmats = getFmatPyramid(PatchSize,PydLev);
        vartheta = ones(size(tempImg));
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

			currentmask=floor((i+1)/2);

			if numel(masks_in_frame)< currentmask
				mask_positions=cell(0);
			else
				mask_positions=masks_in_frame{currentmask};
			end

			converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);



			%% wOFV calculation goes here
			%[x, y, u, v, typevector] = wOFV (image1,image2,converted_mask, roirect);
            
            if strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Off')
                [x,y,u,v,typevector]=wOFVMain_DatasetProc(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,Fmats,PatchSize);
            elseif strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Default')
                [x,y,u,v,typevector]=wOFVMain_Parallel_DatasetProc(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,Fmats,PatchSize);
            else
                PatchSize = str2double(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value});
                [x,y,u,v,typevector]=wOFVMain_Parallel_DatasetProc(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,Fmats,PatchSize);
            end

			correlation_matrices=[];%not available for DCC
			correlation_map=zeros(size(x));

			resultslist{1,(i+1)/2}=x;
			resultslist{2,(i+1)/2}=y;
			resultslist{3,(i+1)/2}=u;
			resultslist{4,(i+1)/2}=v;
			resultslist{5,(i+1)/2}=typevector;
			resultslist{6,(i+1)/2}=[];
			if get(handles.algorithm_selection,'Value')==3 %dcc

			end
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
	cancel=gui.retr('cancel');
	if isempty(cancel)==1 || cancel ~=1
		try
			sound(audioread('finished.mp3'),44100);
		catch
		end
	end
	gui.put('cancel',0);
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
gui.toolsavailable(1);
gui.update_progress(0)
gui.sliderdisp(gui.retr('pivlab_axis'))

