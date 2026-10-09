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
		current_mask_nr=floor(get(handles.fileselector, 'value'));
		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			masks_in_frame=cell(1,current_mask_nr);
		end
		if numel(masks_in_frame)<current_mask_nr
			mask_positions=cell(0);
		else
			mask_positions=masks_in_frame{current_mask_nr};
		end
		u2=[]; v2=[]; umap=[];
		if get(handles.algorithm_selection,'Value')~=4 %FFT, DCC and ensemble (one pair = FFT): shared with the command-line API (pivlab.analyze)
			preproc.Autolimit_Callback %updates the displayed intensity limits
			s = piv.settings_from_gui(handles);
			if strcmp(s.algorithm,'ensemble')
				s.algorithm='fft';
			end
			try
				r = piv.analyze_pair(image1, image2, mask_positions, s);
				x=r.x; y=r.y; u=r.u; v=r.v; typevector=r.typevector;
				correlation_map=r.correlation_map; u2=r.u2; v2=r.v2; umap=r.umap;
			catch ME
				disp(getReport(ME))
				gui.toolsavailable(1);
			end
		else %optical flow
			clahe=get(handles.clahe_enable,'value');
			highp=get(handles.highpass_enable,'value');
			%clip=get(handles.enable_clip,'value');
			intenscap=get(handles.intenscap_enable, 'value');
			clahesize=str2double(get(handles.clahe_size, 'string'));
			highpsize=str2double(get(handles.highpass_size, 'string'));
			wienerwurst=get(handles.wiener_enable, 'value');
			wienerwurstsize=str2double(get(handles.wiener_size, 'string'));
			preproc.Autolimit_Callback
			minintens=str2double(get(handles.minintens, 'string'));
			maxintens=str2double(get(handles.maxintens, 'string'));
			%clipthresh=str2double(get(handles.clip_thresh, 'string'));
			roirect=gui.retr('roirect');
			if get(handles.autolimit_enable, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				if size(image1,3)>1
					stretcher = stretchlim(rgb2gray(image1));
				else
					stretcher = stretchlim(image1);
				end
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
			image1 = preproc.PIVlab_preproc( ...
				in=image1, roirect=roirect, clahe=clahe, clahesize=clahesize, ...
				highp=highp, highpsize=highpsize, intenscap=intenscap, ...
				wienerwurst=wienerwurst, wienerwurstsize=wienerwurstsize, ...
				minintens=minintens, maxintens=maxintens);
			if get(handles.autolimit_enable, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
				if size(image2,3)>1
					stretcher = stretchlim(rgb2gray(image2));
				else
					stretcher = stretchlim(image2);
				end
				minintens = stretcher(1);
				maxintens = stretcher(2);
			end
	
			image2 = preproc.PIVlab_preproc( ...
				in=image2, roirect=roirect, clahe=clahe, clahesize=clahesize, ...
				highp=highp, highpsize=highpsize, intenscap=intenscap, ...
				wienerwurst=wienerwurst, wienerwurstsize=wienerwurstsize, ...
				minintens=minintens, maxintens=maxintens);
	
			converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);
            addpath(genpath(fullfile(fileparts(which('PIVlab_GUI.m')),'OptimizationSolvers'))); %add the optimizer to filepath (absolute: the current folder may be another one)
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
		resultslist{13,(selected+1)/2}=u2;
		resultslist{14,(selected+1)/2}=v2;
		resultslist{15,(selected+1)/2}=umap;
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
		%assignin('base','correlation_matrices',correlation_matrices);
		gui.sliderdisp(gui.retr('pivlab_axis'))
	end

end
