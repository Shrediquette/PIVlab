function correlation_matrices_calculate(~, ~, ~)
handles=gui.gethand;
ok=gui.checksettings;
if ok==1
	resultslist=gui.retr('resultslist');
	if ~isempty(resultslist)
		set(handles.progress, 'string' , ['Frame progress: 0%']);
		set(handles.Settings_Apply_current, 'string' , ['Please wait...']);
		gui.toolsavailable(0,'Getting correlation matrices...');drawnow;
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
			clahe=get(handles.clahe_enable,'value');
			highp=get(handles.enable_highpass,'value');
			intenscap=get(handles.enable_intenscap, 'value');
			clahesize=str2double(get(handles.clahe_size, 'string'));
			highpsize=str2double(get(handles.highp_size, 'string'));
			wienerwurst=get(handles.wienerwurst, 'value');
			wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
			preproc.Autolimit_Callback
			minintens=str2double(get(handles.minintens, 'string'));
			maxintens=str2double(get(handles.maxintens, 'string'));
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
			image1 = preproc.PIVlab_preproc( ...
				in=image1, roirect=roirect, clahe=clahe, clahesize=clahesize, ...
				highp=highp, highpsize=highpsize, intenscap=intenscap, ...
				wienerwurst=wienerwurst, wienerwurstsize=wienerwurstsize, ...
				minintens=minintens, maxintens=maxintens);
			if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
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
			converted_mask=mask.convert_masks_to_binary(size(image1(:,:,1)),mask_positions);
			interrogationarea=str2double(get(handles.intarea, 'string'));
			step=str2double(get(handles.step, 'string'));
			subpixfinder=get(handles.subpix,'value');
			do_correlation_matrices=1;
			if get(handles.algorithm_selection,'Value')==1  %fft
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
						[x, ~, ~, ~, ~,~,correlation_matrices,all_xy_tables] = piv.piv_FFTmulti( ...
							image1=image1, image2=image2, interrogationarea=interrogationarea, step=step, ...
							subpixfinder=subpixfinder, mask_inpt=converted_mask, roi_inpt=roirect, ...
							passes=passes, int2=int2, int3=int3, int4=int4, imdeform=imdeform, ...
							repeat=repeat, mask_auto=mask_auto, do_linear_correlation=do_pad, ...
							do_correlation_matrices=do_correlation_matrices, ...
							repeat_last_pass=repeat_last_pass, delta_diff_min=delta_diff_min);
					catch ME
						disp(getReport(ME))
						gui.toolsavailable(1);
					end
				end
				gui.toolsavailable(1);
				set(handles.progress, 'string' , ['Frame progress: 100%'])
				set(handles.overall, 'string' , ['Total progress: 100%'])
				set(handles.Settings_Apply_current, 'string' , ['Analyze current frame']);
				time1frame=toc;
				set(handles.totaltime, 'String',['Analysis time: ' num2str(round(time1frame*100)/100) ' s']);
				set(handles.messagetext, 'String','');
				% put correlation matrices and information to gui
				correlation_matrices_data.size = size(x);
				correlation_matrices_data.passes = passes;
				correlation_matrices_data.frame = selected;
				correlation_matrices_data.correlation_matrices=correlation_matrices;
				correlation_matrices_data.all_xy_tables=all_xy_tables;
				gui.put('correlation_matrices_data',correlation_matrices_data);
			else
				gui.custom_msgbox('error',getappdata(0,'hgui'),'Not available','Correlation matrices are only available for the ''Multipass FFT window deformation'' algorithm','modal');
				gui.toolsavailable(1);
			end
		end
	else
		gui.custom_msgbox('error',getappdata(0,'hgui'),'No results yet','You need to analyze the current frame before retrieving correlation matrices.','modal');
	end
end
