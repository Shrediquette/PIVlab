% Vector map post processing in PIVlab
function [u_out,v_out] = PIVlab_postproc (u,v,calu,calv, valid_vel, do_stdev_check,stdthresh, do_local_median,neigh_thresh)
%% velocity limits
if numel(valid_vel)>0 %velocity limits were activated
    umin=valid_vel(1);
    umax=valid_vel(2);
    vmin=valid_vel(3);
    vmax=valid_vel(4);
    u(u*calu<umin)=NaN;
    u(u*calu>umax)=NaN;
    v(u*calu<umin)=NaN;
    v(u*calu>umax)=NaN;
    v(v*calv<vmin)=NaN;
	v(v*calv>vmax)=NaN;
	u(v*calv<vmin)=NaN;
	u(v*calv>vmax)=NaN;
end
%% local median check
if do_local_median==1
	neigh_filt=medfilt2(u,[3,3],'symmetric');
	try
		neigh_filt=inpaint_nans(neigh_filt);
	catch %above will fail if all vectos are filtered out before.
		neigh_filt=NaN(size(neigh_filt));
	end
	neigh_filt=abs(neigh_filt-u);
	u(neigh_filt>neigh_thresh)=nan;

	neigh_filt=medfilt2(v,[3,3],'symmetric');
	try
		neigh_filt=inpaint_nans(neigh_filt);
	catch %above will fail if all vectos are filtered out before.
		neigh_filt=NaN(size(neigh_filt));
	end
	neigh_filt=abs(neigh_filt-v);
	v(neigh_filt>neigh_thresh)=nan;
end
%% stddev check
if do_stdev_check==1
    meanu=nanmean(u(:));
    meanv=nanmean(v(:));
    std2u=nanstd(reshape(u,size(u,1)*size(u,2),1));
    std2v=nanstd(reshape(v,size(v,1)*size(v,2),1));
    minvalu=meanu-stdthresh*std2u;
    maxvalu=meanu+stdthresh*std2u;
    minvalv=meanv-stdthresh*std2v;
    maxvalv=meanv+stdthresh*std2v;
    u(u<minvalu)=NaN;
    u(u>maxvalu)=NaN;
    v(v<minvalv)=NaN;
    v(v>maxvalv)=NaN;
end

%% Gradient filter
%{
if do_gradient==1
    u_filled=inpaint_nans(u);
    v_filled=inpaint_nans(v);
    gradient_filt_x =abs(gradient(u_filled));
    gradient_filt_y =abs(gradient(v_filled));
    u(gradient_filt_x>neigh_thresh)=nan;
    v(gradient_filt_y>neigh_thresh)=nan;
end
%}

u(isnan(v))=NaN;
v(isnan(u))=NaN;
u_out=u;
v_out=v;