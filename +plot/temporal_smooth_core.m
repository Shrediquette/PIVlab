function [Us, Vs] = temporal_smooth_core(U, V, use, h, S, do_2d, interp_missing)
%TEMPORAL_SMOOTH_CORE Triangular temporal moving average of a series of velocity fields (no GUI).
%   [Us, Vs] = plot.temporal_smooth_core(U, V, use, h, S, do_2d, interp_missing)
%
%   U, V            1 x N cell arrays with the (filtered) velocity field of every frame
%   use             1 x N logical, frames that take part (false for empty / averaged frames)
%   h               temporal window: number of neighbouring frames on each side
%   S               spatial smoothing parameter (only used when do_2d is true)
%   do_2d           true: every frame is first smoothed spatially (plot.smooth_spatial)
%   interp_missing  false: the original NaN positions of every frame are restored
%
%   Us, Vs          1 x N cell arrays with the smoothed fields ([] for frames not used)
%
%   Each frame's spatial field is computed once, then a NaN-aware triangular (Bartlett)
%   weighted average over frame-h ... frame+h is formed. Used by plot.temporal_smooth_all (GUI)
%   and pivlab.derive.
nframes = numel(U);
Us = cell(1,nframes);
Vs = cell(1,nframes);
% Phase 1: spatial field per frame (computed once). Empty where a frame is absent/averaged.
spatial_u=cell(1,nframes);
spatial_v=cell(1,nframes);
for f=1:nframes
    if ~use(f) || isempty(U{f})
        continue
    end
    uf=U{f}; vf=V{f};
    if do_2d
        [uf,vf]=plot.smooth_spatial(uf,vf,S,interp_missing);
    end
    spatial_u{f}=uf;
    spatial_v{f}=vf;
end

% Phase 2: triangular-weighted, NaN-aware temporal average.
for f=1:nframes
    if isempty(spatial_u{f})
        continue
    end
    refsize=size(spatial_u{f});
    num_u=zeros(refsize); den_u=zeros(refsize);
    num_v=zeros(refsize); den_v=zeros(refsize);
    for d=-h:h
        g=f+d;
        if g<1 || g>nframes || isempty(spatial_u{g}) || ~isequal(size(spatial_u{g}),refsize)
            continue %outside the dataset, missing, or a different grid size
        end
        w=(h+1)-abs(d); %triangular (Bartlett) weight, centred on the current frame
        ug=spatial_u{g}; vu=~isnan(ug); ug(~vu)=0;
        vg=spatial_v{g}; vv=~isnan(vg); vg(~vv)=0;
        num_u=num_u+w*ug; den_u=den_u+w*vu;
        num_v=num_v+w*vg; den_v=den_v+w*vv;
    end
    ubar=num_u./den_u; %0/0 -> NaN where no finite frame in the window
    vbar=num_v./den_v;
    if interp_missing==0
        ubar(isnan(spatial_u{f}))=NaN; %restore this frame's original NaNs (matches 2D smoothing)
        vbar(isnan(spatial_v{f}))=NaN;
    end
    Us{f}=ubar;
    Vs{f}=vbar;
end
end
