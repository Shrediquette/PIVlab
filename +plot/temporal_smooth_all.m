function temporal_smooth_all()
%TEMPORAL_SMOOTH_ALL Efficient whole-dataset temporal moving average ("apply to all frames").
% Each frame's spatial (2D) field is computed ONCE, then the triangular temporal moving
% average is applied across the frames and written into resultslist{10/11,frame}. This
% avoids the per-frame neighbour recomputation that the single-frame plot.temporal_smooth
% performs, so the (expensive) 2D smoothing runs only once per frame instead of once per
% frame-and-window-neighbour. The result is identical to the single-frame path.
% The calculation (plot.temporal_smooth_core) is shared with the command-line API (pivlab.derive).
% The 2D smoothing ("2D + time") is done here frame by frame, with progress in the PIVlab window.
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

% base field per frame (filtered or raw, never the possibly-stale {10/11}); averaged frames do not participate
U=cell(1,nframes);
V=cell(1,nframes);
use=false(1,nframes);
for f=1:nframes
	if numel(resultslist{1,f})==0
		continue
	end
	if ~isempty(ismean) && numel(ismean)>=f && ismean(f)==1
		continue %averaged/STDEV/TKE frames do not participate
	end
	[U{f},V{f}]=base_field(resultslist,f);
	use(f)=~isempty(U{f});
end
W={}; %stereo-PIV: w gets the same moving average (row 17, stereo.w_of_frame)
stereo_mode=isequal(gui.retr('stereomode'),1);
if stereo_mode
	W=cell(1,nframes);
	for f=find(use)
		W{f}=stereo.w_of_frame(f,false,resultslist);
	end
end
if do_2d
	%2D smoothing of every frame (the slow part): done here instead of in plot.temporal_smooth_core
	%to show the progress. Same calculation as in plot.temporal_smooth_core.
	last_draw=tic;
	for f=find(use)
		w=[];
		if stereo_mode
			w=W{f};
		end
		[U{f},V{f},w]=plot.smooth_spatial(U{f},V{f},S,interp_missing,w);
		if stereo_mode
			W{f}=w;
		end
		%progress every 0.25 s (a redraw for every frame would make the smoothing slower), with a full
		%drawnow: the drawnow limitrate in gui.update_progress can skip updates
		if toc(last_draw)>0.25
			gui.update_progress(f/nframes*100)
			drawnow
			last_draw=tic;
		end
	end
end
[Us,Vs,Ws]=plot.temporal_smooth_core(U,V,use,h,S,false,interp_missing,W); %2D smoothing is done above
for f=1:nframes
	if isempty(Us{f})
		continue
	end
	resultslist{10,f}=Us{f};
	resultslist{11,f}=Vs{f};
	if ~isempty(Ws{f})
		resultslist{17,f}=Ws{f};
	end
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
