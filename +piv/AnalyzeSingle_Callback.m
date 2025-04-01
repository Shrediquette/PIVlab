function AnalyzeSingle_Callback(~, ~, ~)
handles=gui.gethand;
ok=gui.checksettings;
if ok==1
	resultslist=gui.retr('resultslist');
	set(handles.progress, 'string' , ['Frame progress: 0%']);
	set(handles.Settings_Apply_current, 'string' , ['Please wait...']);
	gui.toolsavailable(0,'Busy, please wait...');drawnow;
	handles=gui.gethand;
	filepath=gui.retr('filepath');
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	ismean=gui.retr('ismean');
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
		[image1,~]=import.get_img(selected);
		[image2,~]=import.get_img(selected+1);
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
		preproc.Autolimit_Callback
		minintens=str2double(get(handles.minintens, 'string'));
		maxintens=str2double(get(handles.maxintens, 'string'));
		%clipthresh=str2double(get(handles.clip_thresh, 'string'));
		roirect=gui.retr('roirect');
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image1,3)>1
				stretcher = stretchlim(rgb2gray(image1));
			else
				stretcher = stretchlim(image1);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end
		image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image2,3)>1
				stretcher = stretchlim(rgb2gray(image2));
			else
				stretcher = stretchlim(image2);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end

		image2 = preproc.PIVlab_preproc (image2,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);

		current_mask_nr=floor(get(handles.fileselector, 'value'));
		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(current_mask_nr,1);
			masks_in_frame=cell(1,current_mask_nr);
		end
		if numel(masks_in_frame)<current_mask_nr
			mask_positions=cell(0);
		else
			mask_positions=masks_in_frame{current_mask_nr};
		end
		converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);

		interrogationarea=str2double(get(handles.intarea, 'string'));
		step=str2double(get(handles.step, 'string'));
		subpixfinder=get(handles.subpix,'value');
		do_correlation_matrices=gui.retr('do_correlation_matrices');
		if get(handles.algorithm_selection,'Value')==3 %DCC
			[x, y, u, v, typevector] = piv.piv_DCC (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect);
			correlation_map=zeros(size(u)); %nor correlation map available with DCC
			correlation_matrices=[];
		elseif get(handles.algorithm_selection,'Value')==1 || get(handles.algorithm_selection,'Value')==2 %fft and ensemble
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
			[imdeform, repeat, do_pad] = piv.CorrQuality;
			mask_auto = get(handles.mask_auto_box,'value');
			repeat_last_pass = get(handles.repeat_last,'Value');
			delta_diff_min = str2double(get(handles.edit52x,'String'));
			if get(handles.algorithm_selection,'Value')==1 %fft multi
				try
					[x, y, u, v, typevector,correlation_map,correlation_matrices] = piv.piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, converted_mask, roirect,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad,do_correlation_matrices,repeat_last_pass,delta_diff_min);
				catch ME
					disp(getReport(ME))
					gui.toolsavailable(1);
				end
			end
		elseif get(handles.algorithm_selection,'Value')==4 %optical flow
            addpath(genpath('OptimizationSolvers')); %add the optimizer to filepath
			%gui.toolsavailable(1); %re-enabling the ui elements already here, so debugging is easier when things crash. Should be removed when ofv is working.

			etaUnScaled = str2double(get(handles.ofv_eta,'string'));
            PydLev = str2double(handles.ofv_pyramid_levels.String{handles.ofv_pyramid_levels.Value});
            %scaling eta from [0,100] to [1e-5,1e5]
            eta = 10^(etaUnScaled*0.1 - 5);

            vartheta = ones(size(image1));
            if strcmp(handles.ofv_median.String{handles.ofv_median.Value},'Off')
                MedFiltFlag = false;
                MedFiltSize = [3,3];
          
            else
                MedFiltFlag = true;
                MedFiltSize = [str2double(handles.ofv_median.String{handles.ofv_median.Value}(1)),str2double(handles.ofv_median.String{handles.ofv_median.Value}(3))];
            end
            
			if strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Off')
				[x,y,u,v,typevector]=wOFV.RunMain(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev);
			elseif strcmp(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value},'Default')
				[x,y,u,v,typevector]=wOFV.RunMain_Parallel(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,[]);
			else
				PatchSize = str2double(handles.ofv_parallelpatches.String{handles.ofv_parallelpatches.Value});
				[x,y,u,v,typevector]=wOFV.RunMain_Parallel(image1,image2,converted_mask,roirect,eta,vartheta,MedFiltFlag,MedFiltSize,PydLev,PatchSize);
			end

			correlation_map=zeros(size(x)); %no correlation map available with OFV (?) Nope!
			correlation_matrices=[];
		elseif get(handles.algorithm_selection,'Value')==5 %particle streak velocimetry PSV
			img_BW = imbinarize(image1, str2double(get(handles.psv_threshold,'String')));
			binsize=str2double(get(handles.psv_binsize,'String'));
			% run particle streak velocimetry  code
			[x,y,u,v,typevector,correlation_map] = psv.psv_code(img_BW, binsize,roirect,converted_mask);
			%correlation_map=zeros(size(x));
			correlation_matrices=[];
		end
		gui.toolsavailable(1);
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
		gui.put('derived', [])
		gui.put('resultslist',resultslist);
		set(handles.progress, 'string' , ['Frame progress: 100%'])
		set(handles.overall, 'string' , ['Total progress: 100%'])
		set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
		time1frame=toc;
		set(handles.totaltime, 'String',['Analysis time: ' num2str(round(time1frame*100)/100) ' s']);
		set(handles.messagetext, 'String','');
		gui.put('subtr_u', 0);
		gui.put('subtr_v', 0);
		assignin('base','correlation_matrices',correlation_matrices);
		gui.sliderdisp(gui.retr('pivlab_axis'))
	end

end

