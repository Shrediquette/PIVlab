function [u,v]=smooth_spatial(u,v,S,interp_missing)
%SMOOTH_SPATIAL 2D spatial smoothing of one velocity field (u,v).
% Uses "smoothn" by Damien Garcia with smoothing parameter S. When "interpolate
% missing data" is off, the original NaN positions are restored after smoothing.
% Falls back to a Gaussian kernel on old MATLAB versions without smoothn.
u_old=u; v_old=v;
try
	u=misc.smoothn(u,S);
	v=misc.smoothn(v,S);
	if interp_missing==0 %user does not want to interpolate missing data, but wants to smooth anyway
		u(isnan(u_old))=NaN;
		v(isnan(v_old))=NaN;
	end
catch
	win=max(1,round(S*10)); %derive a kernel size from S for the legacy fallback
	h=fspecial('gaussian',win+2,(win+2)/7);
	u=imfilter(u,h,'replicate');
	v=imfilter(v,h,'replicate');
	%disp ('Using Gaussian kernel for data smoothing (your Matlab version is pretty old btw...).')
end

end
