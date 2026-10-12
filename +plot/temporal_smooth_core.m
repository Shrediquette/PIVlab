function [Us, Vs, Ws] = temporal_smooth_core(U, V, use, h, S, do_2d, interp_missing, W)
%TEMPORAL_SMOOTH_CORE Triangular temporal moving average of a series of velocity fields (no GUI).
%   [Us, Vs] = plot.temporal_smooth_core(U, V, use, h, S, do_2d, interp_missing)
%   [Us, Vs, Ws] = plot.temporal_smooth_core(..., W)   with the out-of-plane component (stereo-PIV)
%
%   U, V            1 x N cell arrays with the (filtered) velocity field of every frame
%   use             1 x N logical, frames that take part (false for empty / averaged frames)
%   h               temporal window: number of neighbouring frames on each side
%   S               spatial smoothing parameter (only used when do_2d is true)
%   do_2d           true: every frame is first smoothed spatially (plot.smooth_spatial)
%   interp_missing  false: the original NaN positions of every frame are restored
%   W (optional)    1 x N cell array with the out-of-plane component w (stereo-PIV), smoothed
%                   exactly like u and v
%
%   Us, Vs, Ws      1 x N cell arrays with the smoothed fields ([] for frames not used)
%
%   Each frame's spatial field is computed once, then a NaN-aware triangular (Bartlett)
%   weighted average over frame-h ... frame+h is formed. Used by plot.temporal_smooth_all (GUI)
%   and pivlab.derive.
nframes = numel(U);
has_w = nargin >= 8 && ~isempty(W);
Us = cell(1,nframes);
Vs = cell(1,nframes);
Ws = cell(1,nframes);
% Phase 1: spatial field per frame (computed once). Empty where a frame is absent/averaged.
spatial_u=cell(1,nframes);
spatial_v=cell(1,nframes);
spatial_w=cell(1,nframes);
for f=1:nframes
    if ~use(f) || isempty(U{f})
        continue
    end
    uf=U{f}; vf=V{f};
    wf=[];
    if has_w
        wf=W{f};
    end
    if do_2d
        [uf,vf,wf]=plot.smooth_spatial(uf,vf,S,interp_missing,wf);
    end
    spatial_u{f}=uf;
    spatial_v{f}=vf;
    spatial_w{f}=wf;
end

% Phase 2: triangular-weighted, NaN-aware temporal average, the same for every component.
for f=1:nframes
    if isempty(spatial_u{f})
        continue
    end
    Us{f}=window_average(spatial_u,f,h,interp_missing);
    Vs{f}=window_average(spatial_v,f,h,interp_missing);
    if ~isempty(spatial_w{f})
        Ws{f}=window_average(spatial_w,f,h,interp_missing);
    end
end
end

function xbar=window_average(fields,f,h,interp_missing)
%Triangular (Bartlett) weighted average of one component over the frames f-h ... f+h; NaN-aware.
nframes=numel(fields);
refsize=size(fields{f});
num=zeros(refsize); den=zeros(refsize);
for d=-h:h
    g=f+d;
    if g<1 || g>nframes || isempty(fields{g}) || ~isequal(size(fields{g}),refsize)
        continue %outside the dataset, missing, or a different grid size
    end
    wt=(h+1)-abs(d); %triangular weight, centred on the current frame
    xg=fields{g}; valid=~isnan(xg); xg(~valid)=0;
    num=num+wt*xg; den=den+wt*valid;
end
xbar=num./den; %0/0 -> NaN where no finite frame in the window
if interp_missing==0
    xbar(isnan(fields{f}))=NaN; %restore this frame's original NaNs (matches 2D smoothing)
end
end
