function [u,v,w]=smooth_spatial(u,v,S,interp_missing,w)
%SMOOTH_SPATIAL 2D spatial smoothing of one velocity field (u,v), optionally with w.
%   [u,v]=plot.smooth_spatial(u,v,S,interp_missing)
%   [u,v,w]=plot.smooth_spatial(u,v,S,interp_missing,w)   w: out-of-plane component (stereo-PIV),
%                                                          smoothed exactly like u and v ([] = none)
% Uses "smoothn" by Damien Garcia with smoothing parameter S. When "interpolate
% missing data" is off, the original NaN positions are restored after smoothing.
% Falls back to a Gaussian kernel on old MATLAB versions without smoothn.
if nargin<5
	w=[];
end
u=smooth_component(u,S,interp_missing);
v=smooth_component(v,S,interp_missing);
if ~isempty(w)
	w=smooth_component(w,S,interp_missing);
end
end

function x=smooth_component(x,S,interp_missing)
x_old=x;
try
	x=misc.smoothn(x,S);
	if interp_missing==0 %user does not want to interpolate missing data, but wants to smooth anyway
		x(isnan(x_old))=NaN;
	end
catch
	win=max(1,round(S*10)); %derive a kernel size from S for the legacy fallback
	h=fspecial('gaussian',win+2,(win+2)/7);
	x=imfilter(x_old,h,'replicate');
	%disp ('Using Gaussian kernel for data smoothing (your Matlab version is pretty old btw...).')
end
end
