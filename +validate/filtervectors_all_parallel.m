function [u,v,typevector]=filtervectors_all_parallel(x,y,u,v,typevector_original,calu,calv,velrect,do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter,contrast_filter_thresh,bright_filter_thresh,interpol_missing,A,B,rawimageA,rawimageB,do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh,roi_freehand)
typevector=typevector_original;
%run postprocessing function
if numel(velrect)>0
	valid_vel(1)=velrect(1); %umin
	valid_vel(2)=velrect(3)+velrect(1); %umax
	valid_vel(3)=velrect(2); %vmin
	valid_vel(4)=velrect(4)+velrect(2); %vmax
else
	valid_vel=[];
end
%do_contrast_filter=1
if ~isempty(x)
	if do_contrast_filter == 1 || do_bright_filter == 1
		[u,v,~,~,~] = postproc.PIVlab_image_filter (do_contrast_filter,do_bright_filter,x,y,u,v,contrast_filter_thresh,bright_filter_thresh,A,B,rawimageA,rawimageB);
	end
else
	u=[];v=[];
end

%correlation filter
if ~isempty(x)
	if do_corr2_filter == 1
		[u,v] = postproc.PIVlab_correlation_filter (u,v,corr_filter_thresh,corr2_value);
	end
else
	u=[];v=[];
end

%Notch velocity magnitude filter
if ~isempty(x)
	if do_notch_filter == 1
		[u,v] = postproc.PIVlab_notch_filter (u,v,calu,calv,notch_L_thresh,notch_H_thresh);
	end
end

% freehand velocity limit filter (new in v3.10)
if ~isempty(roi_freehand) && ~isempty(u)
	nanMask_u = isnan(u); % Define nan mask
	nanMask_v = isnan(v); % Define nan mask
	u(nanMask_u)=0;
	v(nanMask_v)=0;
	tf = inROI(roi_freehand,double(u*calu),double(v*calv));
	%restore nans from previous filters
	u(nanMask_u)=NaN;
	v(nanMask_v)=NaN;
	u(tf==0)=nan;
	v(tf==0)=nan;
end

if ~isempty(x)
	%vector-based filtering
	[u,v] = postproc.PIVlab_postproc (u,v,calu,calv,valid_vel, do_stdev_check,stdthresh, do_local_median,neigh_thresh);
else
	u=[];v=[];
end

typevector(isnan(u))=2;
typevector(isnan(v))=2;
typevector(typevector_original==0)=0; %restores typevector for mask
%interpolation using inpaint_NaNs
if interpol_missing==1
	u=misc.inpaint_nans(u,4);
	v=misc.inpaint_nans(v,4);
end

