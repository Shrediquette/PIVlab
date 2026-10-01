function filtervectors(frame)
%executes filters one after another, writes results to resultslist 7,8,9
%The filtering itself (validate.filtervectors_all_parallel) is shared with the parallel
%GUI path and with the command-line API (pivlab.filter).
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
			[u,v,typevector]=validate.manual_point_deletion(u,v,typevector,framemanualdeletion); %#ok<ASGLU>
		end
	end
	if numel(u)>0
		x=resultslist{1,frame};
		y=resultslist{2,frame};
		velrect=gui.retr('velrect');
		do_stdev_check = get(handles.stdev_check, 'value');
		stdthresh=str2double(get(handles.stdev_thresh, 'String'));
		do_local_median = get(handles.loc_median, 'value');
		neigh_thresh=str2double(get(handles.loc_med_thresh,'string'));

		%image-based filtering
		do_contrast_filter = get(handles.do_contrast_filter, 'value');
		do_bright_filter = get(handles.do_bright_filter, 'value');
		contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
		bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));
		A=[]; B=[]; rawimageA=[]; rawimageB=[];
		if do_contrast_filter == 1 || do_bright_filter == 1
			selected=2*frame-1;
			[A,rawimageA]=import.get_img(selected);
			[B,rawimageB]=import.get_img(selected+1);
		end

		%correlation filter
		do_corr2_filter = get(handles.do_corr2_filter, 'value');
		corr_filter_thresh=str2double(get(handles.corr_filter_thresh,'String'));
		corr2_value=[];
		if size(resultslist,1)>=12
			corr2_value=resultslist{12,frame};
		end

		%Notch velocity magnitude filter
		do_notch_filter = get(handles.notch_filter, 'value');
		notch_L_thresh=str2double(get(handles.notch_L_thresh,'String'));
		notch_H_thresh=str2double(get(handles.notch_H_thresh,'String'));

		% freehand velocity limit filter (new in v3.10)
		velrect_freehand=gui.retr('velrect_freehand');
		if ~isempty(velrect_freehand)
			roi_freehand = images.roi.Freehand('Position',velrect_freehand);
		else
			roi_freehand=[];
		end

		% Second-peak substitution: u2/v2 of the analysis (if available)
		u2=[]; v2=[];
		if size(resultslist,1) >= 13
			u2=resultslist{13,frame};
			v2=resultslist{14,frame};
		end

		[u,v,typevector]=validate.filtervectors_all_parallel(x,y,u,v,typevector_original,calu,calv,velrect, ...
			do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter, ...
			contrast_filter_thresh,bright_filter_thresh,get(handles.interpol_missing, 'value'),A,B,rawimageA,rawimageB, ...
			do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh,roi_freehand,u2,v2);

		resultslist{7, frame} = u;
		resultslist{8, frame} = v;
		resultslist{9, frame} = typevector;
		gui.put('resultslist', resultslist);
	end
end
