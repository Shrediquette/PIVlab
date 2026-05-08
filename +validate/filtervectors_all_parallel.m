function [u,v,typevector]=filtervectors_all_parallel(x,y,u,v,typevector_original,calu,calv,velrect,do_stdev_check,stdthresh,do_local_median,neigh_thresh,do_contrast_filter,do_bright_filter,contrast_filter_thresh,bright_filter_thresh,interpol_missing,A,B,rawimageA,rawimageB,do_corr2_filter,corr_filter_thresh,corr2_value,do_notch_filter,notch_L_thresh,notch_H_thresh,roi_freehand,u2,v2)
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
[u,v] = postproc.PIVlab_postproc( ...
    u=u, v=v, calu=calu, calv=calv, valid_vel=valid_vel, ...
    do_stdev_check=do_stdev_check, stdthresh=stdthresh, ...
    do_local_median=do_local_median, neigh_thresh=neigh_thresh);
else
	u=[];v=[];
end

typevector(isnan(u))=2;
typevector(isnan(v))=2;
% Second-peak substitution: try u2/v2 where primary validation rejected a vector
enable_second_peak_substitution = true; % set to false to disable
if enable_second_peak_substitution && ~isempty(u2) && ~isempty(v2)
	u2=single(u2); v2=single(v2);
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
if interpol_missing==1
	u=misc.inpaint_nans(u,4);
	v=misc.inpaint_nans(v,4);
end
