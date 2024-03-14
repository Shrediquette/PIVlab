function validate_apply_filter_all_Callback(~, ~, ~)
resultslist=gui.gui_retr('resultslist');

if ~isempty(resultslist)
	handles=gui.gui_gethand;
	filepath=gui.gui_retr('filepath');
	gui.gui_toolsavailable(0,'Busy, please wait...')
	gui.gui_put('derived', []); %clear derived parameters if user modifies source data
	if gui.gui_retr('video_selection_done') == 0
		num_frames_to_process=floor(size(filepath,1)/2)+1;
	else
		video_frame_selection=gui.gui_retr('video_frame_selection');
		num_frames_to_process=floor(numel(video_frame_selection)/2)+1;
	end
	if gui.gui_retr('video_selection_done') == 1 || gui.gui_retr('parallel')==0 %if post-processing a video, parallelization cannot be used.
		for i=1:num_frames_to_process
			validate.validate_filtervectors(i)
			set (handles.apply_filter_all, 'string', ['Please wait... (' int2str((i-1)/num_frames_to_process*100) '%)']);
			drawnow;
		end
	else %not using a video file --> parallel processing possible
		slicedfilepath1=cell(0);
		slicedfilepath2=cell(0);
		for i=1:2:size(filepath,1)%num_frames_to_process
			k=(i+1)/2;
			slicedfilepath1{k}=filepath{i};
			slicedfilepath2{k}=filepath{i+1};
		end
		if get(handles.bg_subtract,'Value')==1
			bg_img_A = gui.gui_retr('bg_img_A');
			bg_img_B = gui.gui_retr('bg_img_B');
			bg_sub=1;
		else
			bg_img_A=[];
			bg_img_B=[];
			bg_sub=0;
		end
		resultslist(10,:)={[]}; %remove smoothed results when user modifies original data
		resultslist(11,:)={[]};
		calu=gui.gui_retr('calu');calv=gui.gui_retr('calv');
		x=resultslist(1,:);
		y=resultslist(2,:);
		u=resultslist(3,:);
		v=resultslist(4,:);
		typevector=resultslist(5,:);
		typevector_original=resultslist(5,:);
		manualdeletion=gui.gui_retr('manualdeletion');

		if numel(manualdeletion)>0
			for i=1:size(u,2)
				if size(manualdeletion,2)>=i
					if isempty(manualdeletion{1,i}) ==0
						framemanualdeletion=manualdeletion{i};
						[u{i},v{i},typevector{i}]=validate.validate_manual_point_deletion(u{i},v{i},typevector{i},framemanualdeletion);
					end
				end
			end
		end
		velrect=gui.gui_retr('velrect');
		do_stdev_check = get(handles.stdev_check, 'value');
		stdthresh=str2double(get(handles.stdev_thresh, 'String'));
		do_local_median = get(handles.loc_median, 'value');
		neigh_thresh=str2double(get(handles.loc_med_thresh,'string'));
		%image-based filtering
		do_contrast_filter = get(handles.do_contrast_filter, 'value');
		do_bright_filter = get(handles.do_bright_filter, 'value');
		contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
		bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));
		interpol_missing= get(handles.interpol_missing, 'value');
		do_corr2_filter = get(handles.do_corr2_filter, 'value');
		corr_filter_thresh=str2double(get(handles.corr_filter_thresh,'String'));
		do_notch_filter = get(handles.notch_filter, 'value');
		notch_L_thresh=str2double(get(handles.notch_L_thresh,'String'));
		notch_H_thresh=str2double(get(handles.notch_H_thresh,'String'));

		hbar = pivprogress(size(slicedfilepath1,2),handles.apply_filter_all);
		if size(u,2)<num_frames_to_process-1 %If not all frames have been analyzed. Parfor loop crashes otherwise.
			u(num_frames_to_process-1)={[]};
			v(num_frames_to_process-1)={[]};
			x(num_frames_to_process-1)={[]};
			y(num_frames_to_process-1)={[]};
			typevector_original(num_frames_to_process-1)={[]};
			resultslist(1,num_frames_to_process-1)={[]};
		end
		parfor i=1:num_frames_to_process-1 %without parallel processing toolbox, this is just a normal for loop.
			if ~isempty(x(i))
				if do_contrast_filter == 1 || do_bright_filter == 1
					%% load images in a parfor loop
					[~,~,ext] = fileparts(slicedfilepath1{i});
					if strcmp(ext,'.b16')
						currentimage1=f_readB16(slicedfilepath1{i});
						currentimage2=f_readB16(slicedfilepath2{i});
					else
						currentimage1=imread(slicedfilepath1{i});
						currentimage2=imread(slicedfilepath2{i});
					end
					rawimageA=currentimage1;
					rawimageB=currentimage2;
					if bg_sub==1
						if size(currentimage1,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
							currentimage1 = rgb2gray(currentimage1)-bg_img_A;
							currentimage2 = rgb2gray(currentimage2)-bg_img_B;
						else
							currentimage1 = currentimage1-bg_img_A;
							currentimage2 = currentimage2-bg_img_B;
						end
					end
					currentimage1(currentimage1<0)=0; %bg subtraction may yield negative
					currentimage2(currentimage2<0)=0; %bg subtraction may yield negative
					A=currentimage1;
					B=currentimage2;
				else
					A=[];B=[];rawimageA=[];rawimageB=[];
				end
				corr2_value=resultslist{12,i};
				[u_new{i},v_new{i},typevector_new{i}]=validate.validate_filtervectors_all_parallel(x{i},y{i},u{i},v{i},typevector_original{i},calu,calv,velrect,do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter,contrast_filter_thresh,bright_filter_thresh,interpol_missing,A,B,rawimageA,rawimageB,do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh);
				hbar.iterate(1); %#ok<*PFBNS>
			end
		end
		close(hbar);

		%% 3D local median filtering test
		%{
		neigh_thresh=3;
		u=u_new;%resultslist(3,:);
		v=v_new;%resultslist(4,:);

		u_3d = cat(3,u{:});
		v_3d = cat(3,v{:});
	
		neigh_filt=medfilt3(u_3d);
		neigh_filt=fillmissing(neigh_filt,'linear');
		neigh_filt=abs(neigh_filt-u_3d);
		u_3d(neigh_filt>neigh_thresh)=nan;
		neigh_filt=medfilt3(v_3d);
		neigh_filt=fillmissing(neigh_filt,'linear');
		neigh_filt=abs(neigh_filt-v_3d);
		v_3d(neigh_filt>neigh_thresh)=nan;
	
		u = squeeze(num2cell(u_3d, [1,2]))';
		v = squeeze(num2cell(v_3d, [1,2]))';
		
		u_new=u;
		v_new=v;
		%}
		resultslist(7, :) = u_new;
		resultslist(8, :) = v_new;
		resultslist(9, :) = typevector_new;
		gui.gui_put('resultslist', resultslist);
	end
	set (handles.apply_filter_all, 'string', 'Apply to all frames');
	gui.gui_toolsavailable(1)
	gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));
end

