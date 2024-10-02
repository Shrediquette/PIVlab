function filtervectors(frame)
%executes filters one after another, writes results to resultslist 7,8,9
handles=gui.gethand;
resultslist=gui.retr('resultslist');
resultslist{10,frame}=[]; %remove smoothed results when user modifies original data
resultslist{11,frame}=[];
if size(resultslist,2)>=frame
	calu=gui.retr('calu');calv=gui.retr('calv');
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	typevector_original=resultslist{5,frame};
	typevector=typevector_original;
	manualdeletion=gui.retr('manualdeletion');
	if size(manualdeletion,2)>=frame
		if isempty(manualdeletion{1,frame}) ==0
			framemanualdeletion=manualdeletion{frame};
			[u,v,typevector]=validate.manual_point_deletion(u,v,typevector,framemanualdeletion);
		end
	end
	if numel(u)>0
		velrect=gui.retr('velrect');
		do_stdev_check = get(handles.stdev_check, 'value');
		stdthresh=str2double(get(handles.stdev_thresh, 'String'));
		do_local_median = get(handles.loc_median, 'value');
		%epsilon=str2double(get(handles.epsilon,'string'));
		neigh_thresh=str2double(get(handles.loc_med_thresh,'string'));



		%run postprocessing function
		if numel(velrect)>0
			valid_vel(1)=velrect(1); %umin
			valid_vel(2)=velrect(3)+velrect(1); %umax
			valid_vel(3)=velrect(2); %vmin
			valid_vel(4)=velrect(4)+velrect(2); %vmax
		else
			valid_vel=[];
		end

		%image-based filtering
		do_contrast_filter = get(handles.do_contrast_filter, 'value');
		do_bright_filter = get(handles.do_bright_filter, 'value');
		%do_contrast_filter=1
		if do_contrast_filter == 1 || do_bright_filter == 1
			selected=2*frame-1;
			x=resultslist{1,frame};
			y=resultslist{2,frame};
			contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
			bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));

			[A,rawimageA]=import.get_img(selected);
			[B,rawimageB]=import.get_img(selected+1);
			[u,v,~,~,~] = postproc.PIVlab_image_filter (do_contrast_filter,do_bright_filter,x,y,u,v,contrast_filter_thresh,bright_filter_thresh,A,B,rawimageA,rawimageB);
		end

		%correlation filter
		do_corr2_filter = get(handles.do_corr2_filter, 'value');
		if do_corr2_filter == 1
			corr_filter_thresh=str2double(get(handles.corr_filter_thresh,'String'));
			[u,v] = postproc.PIVlab_correlation_filter (u,v,corr_filter_thresh,resultslist{12,frame});
		end

		%Notch velocity magnitude filter
		do_notch_filter = get(handles.notch_filter, 'value');
		if do_notch_filter == 1
			[u,v] = postproc.PIVlab_notch_filter (u,v,calu,calv,str2double(get(handles.notch_L_thresh,'String')),str2double(get(handles.notch_H_thresh,'String')));
		end

		%vector-based filtering
		[u,v] = postproc.PIVlab_postproc (u,v,calu,calv,valid_vel, do_stdev_check,stdthresh, do_local_median,neigh_thresh);

		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
		typevector(typevector_original==0)=0; %restores typevector for mask
		%interpolation using inpaint_NaNs
		if get(handles.interpol_missing, 'value')==1
			u=misc.inpaint_nans(u,4);
			v=misc.inpaint_nans(v,4);
		end
		resultslist{7, frame} = u;
		resultslist{8, frame} = v;
		resultslist{9, frame} = typevector;
		gui.put('resultslist', resultslist);
	end
end

