function temporal_smooth_all()
%TEMPORAL_SMOOTH_ALL Efficient whole-dataset temporal moving average ("apply to all frames").
% Each frame's spatial (2D) field is computed ONCE, then the triangular temporal moving
% average is applied across the frames and written into resultslist{10/11,frame}. This
% avoids the per-frame neighbour recomputation that the single-frame plot.temporal_smooth
% performs, so the (expensive) 2D smoothing runs only once per frame instead of once per
% frame-and-window-neighbour. The result is identical to the single-frame path.
%
% Only runs for the temporal smoothing modes: 3 = time, 4 = 2D + time.

handles=gui.gethand;
smooth_mode=get(handles.smooth_mode,'Value');
if smooth_mode~=3 && smooth_mode~=4
	return
end
do_2d=(smooth_mode==4);
resultslist=gui.retr('resultslist');
nframes=size(resultslist,2);
if nframes<1
	return
end

h=round(str2double(get(handles.temporal_window,'String'))); %neighbours on each side
if isnan(h) || h<1
	h=2; set(handles.temporal_window,'String','2');
end

S=str2double(get(handles.smooth_param,'String'));
if isnan(S) || S<=0
	S=0.2;
end
interp_missing=get(handles.interpol_missing,'value');
ismean=gui.retr('ismean');

% Phase 1: spatial field per frame (computed once). Empty where a frame is absent/averaged.
spatial_u=cell(1,nframes);
spatial_v=cell(1,nframes);
for f=1:nframes
	if numel(resultslist{1,f})==0
		continue
	end
	if ~isempty(ismean) && numel(ismean)>=f && ismean(f)==1
		continue %averaged/STDEV/TKE frames do not participate
	end
	[uf,vf]=base_field(resultslist,f);
	if isempty(uf)
		continue
	end
	if do_2d
		[uf,vf]=plot.smooth_spatial(uf,vf,S,interp_missing);
	end
	spatial_u{f}=uf;
	spatial_v{f}=vf;
end

% Phase 2: triangular-weighted, NaN-aware temporal average; write back to {10/11}.
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
	resultslist{10,f}=ubar;
	resultslist{11,f}=vbar;
end
gui.put('resultslist',resultslist);

end

% ------------------------------------------------------------------------------------------

function [u,v]=base_field(resultslist,f)
%Filtered (or raw) velocity field for frame f, never the smoothed {10/11}.
u=[]; v=[];
if numel(resultslist{1,f})==0
	return
end
if size(resultslist,1)>6 && numel(resultslist{7,f})>0
	u=resultslist{7,f};
	v=resultslist{8,f};
else
	u=resultslist{3,f};
	v=resultslist{4,f};
end
end
