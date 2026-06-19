function [u,v]=temporal_smooth(resultslist,frame,u,v)
%TEMPORAL_SMOOTH Temporal moving average of one frame over neighbouring frames.
% Returns the temporally-averaged velocity (u,v) for `frame`, averaging over the
% frames (2nd dimension of resultslist = time) within a centred window. The window
% neighbours are read/computed in local memory only — their stored results are NOT
% modified. The caller (plot.derivative_calc) passes in the already spatially-processed
% (u,v) for the current frame and stores the returned fields into resultslist{10/11,frame}.
%
% The "Temporal window" value is the number of neighbouring frames used on EACH side
% (half-width h): the window spans frame-h ... frame+h (2*h+1 frames). The frames are
% combined with a TRIANGULAR (Bartlett) weighting centred on the current frame, so the
% current frame counts most and the influence of a neighbour falls off linearly with its
% distance in time. For h=1 the weights are [0.25 0.5 0.25].
%
% Mask/NaN handling is identical to the 2D smoothing (plot.smooth_spatial): masked cells
% are kept as numeric (smoothed) values rather than being forced to NaN, so derived
% quantities stay defined up to the mask edge; only the current frame's original NaN
% positions are restored when "interpolate missing data" is off.

handles=gui.gethand;
smooth_mode=get(handles.smooth_mode,'Value'); % 3 = time, 4 = 2D + time
do_2d=(smooth_mode==4); %neighbours get the 2D smoothing too in "2D + time" mode

%temporal window = number of neighbouring frames on each side (half-width)
h=round(str2double(get(handles.temporal_window,'String')));
if isnan(h) || h<1
	h=2; set(handles.temporal_window,'String','2');
end
if h<1
	return %no neighbours --> nothing to average, return (u,v) unchanged
end

S=str2double(get(handles.smooth_param,'String'));
if isnan(S) || S<=0
	S=0.2;
end
interp_missing=get(handles.interpol_missing,'value');
ismean=gui.retr('ismean');
nframes=size(resultslist,2);
refsize=size(u);

%triangular (Bartlett) weights for offsets -h..h: w(d) = (h+1) - |d|
offs=-h:h;
wts=(h+1)-abs(offs);

stack_u=nan([refsize numel(offs)]);
stack_v=stack_u;
idx=0;
for f=frame-h:frame+h
	idx=idx+1;
	if f==frame
		uf=u; vf=v; %current frame: use the spatially-processed field passed in
	else
		if f<1 || f>nframes || numel(resultslist{1,f})==0
			continue %outside the dataset or not analyzed
		end
		if ~isempty(ismean) && numel(ismean)>=f && ismean(f)==1
			continue %averaged/STDEV/TKE frames must not contribute
		end
		[uf,vf]=local_base(resultslist,f); %filtered/raw base (never the possibly-stale {10/11})
		if isempty(uf) || ~isequal(size(uf),refsize)
			continue %missing or a different grid size --> skip
		end
		if do_2d
			[uf,vf]=plot.smooth_spatial(uf,vf,S,interp_missing);
		end
	end
	stack_u(:,:,idx)=uf;
	stack_v(:,:,idx)=vf;
end

%NaN-aware weighted average over time: sum(w*x) / sum(w) over the finite frames only.
%End frames and missing/masked points use the weights of the available frames (renormalized).
W=reshape(wts,1,1,[]);
validu=~isnan(stack_u); su=stack_u; su(~validu)=0;
validv=~isnan(stack_v); sv=stack_v; sv(~validv)=0;
ubar=sum(su.*W,3)./sum(W.*validu,3); %0/0 -> NaN where no finite frame in the window
vbar=sum(sv.*W,3)./sum(W.*validv,3);

%Mask/NaN handling identical to the 2D smoothing (plot.smooth_spatial): masked cells are
%left as numeric (smoothed) values - NOT forced to NaN - so derived quantities (vorticity
%etc.) stay defined right up to the mask edge. Only original NaN positions are restored.
if interp_missing==0
	ubar(isnan(u))=NaN; vbar(isnan(v))=NaN; %restore the current frame's original NaNs
end
u=ubar; v=vbar;

end

% ------------------------------------------------------------------------------------------

function [u,v]=local_base(resultslist,f)
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
