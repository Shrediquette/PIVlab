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

		% freehand velocity limit filter (new in v3.10)
		velrect_freehand=gui.retr('velrect_freehand');
		if ~isempty(velrect_freehand)
			nanMask_u = isnan(u); % Define nan mask
			nanMask_v = isnan(v); % Define nan mask
			u(nanMask_u)=0;
			v(nanMask_v)=0;
			roi = images.roi.Freehand('Position',velrect_freehand);
			tf = inROI(roi,double(u*calu),double(v*calv));
			%restore nans from previous filters
			u(nanMask_u)=NaN;
			v(nanMask_v)=NaN;
			u(tf==0)=nan;
			v(tf==0)=nan;
		end

		%vector-based filtering
[u,v] = postproc.PIVlab_postproc( ...
    u=u, v=v, calu=calu, calv=calv, valid_vel=valid_vel, ...
    do_stdev_check=do_stdev_check, stdthresh=stdthresh, ...
    do_local_median=do_local_median, neigh_thresh=neigh_thresh);

		typevector(isnan(u))=2;
		typevector(isnan(v))=2;
		% Second-peak substitution: try u2/v2 where primary validation rejected a vector
		enable_second_peak_substitution = true; % set to false to disable
		if enable_second_peak_substitution && size(resultslist,1) >= 13 && ~isempty(resultslist{13,frame}) && ~isempty(resultslist{14,frame})
			u2=single(resultslist{13,frame});
			v2=single(resultslist{14,frame});
			candidates=(typevector==2) & ~isnan(u2) & ~isnan(v2) & (typevector_original~=0);
			if any(candidates(:))
				% Build smooth scaffold from valid primaries only (no u2/v2).
				% All validation statistics are derived from the scaffold so that
				% candidates never influence each other's neighborhood — dense clusters
				% of bad u2/v2 cannot mask each other as they would if inserted first.
				u_scaffold=misc.inpaint_nans(u,4);
				v_scaffold=misc.inpaint_nans(v,4);
				accepted=candidates;
				% Velocity limits — per-vector, coupled rejection matches PIVlab_postproc
				if numel(valid_vel)>0
					bad=(u2*calu<valid_vel(1))|(u2*calu>valid_vel(2))|(v2*calv<valid_vel(3))|(v2*calv>valid_vel(4));
					accepted=accepted & ~bad;
				end
				% Normalized median test (Westerweel & Scarano 2005) against scaffold
				if do_local_median==1
					eps_ws=0.1; b=2;
					MedianU=medfilt2(u_scaffold,[2*b+1,2*b+1],'symmetric');
					MedianV=medfilt2(v_scaffold,[2*b+1,2*b+1],'symmetric');
					MedianResU=medfilt2(abs(u_scaffold-MedianU),[2*b+1,2*b+1],'symmetric');
					MedianResV=medfilt2(abs(v_scaffold-MedianV),[2*b+1,2*b+1],'symmetric');
					NormU=abs((u2-MedianU)./(MedianResU+eps_ws));
					NormV=abs((v2-MedianV)./(MedianResV+eps_ws));
					accepted=accepted & (sqrt(NormU.^2+NormV.^2)<=neigh_thresh);
				end
				% Global stdev — computed from valid primary vectors, not scaffold
				if do_stdev_check==1
					meanu=mean(u(:),'omitnan'); meanv=mean(v(:),'omitnan');
					stdu=std(u(:),'omitnan');   stdv=std(v(:),'omitnan');
					accepted=accepted & (u2>=meanu-stdthresh*stdu) & (u2<=meanu+stdthresh*stdu);
					accepted=accepted & (v2>=meanv-stdthresh*stdv) & (v2<=meanv+stdthresh*stdv);
				end
				u(accepted)=u2(accepted);
				v(accepted)=v2(accepted);
				typevector(accepted)=3;
			end
		end
		typevector(typevector_original==0)=0; %restores typevector for mask
		%interpolation using inpaint_NaNs
		if get(handles.interpol_missing, 'value')==1
			try
				u=misc.inpaint_nans(u,4);
			catch
				disp('too many missing vectors, can not interpolate.')
			end
			try
				v=misc.inpaint_nans(v,4);
			catch
				disp('too many missing vectors, can not interpolate.')
			end
		end
		resultslist{7, frame} = u;
		resultslist{8, frame} = v;
		resultslist{9, frame} = typevector;
		gui.put('resultslist', resultslist);
	end
end
