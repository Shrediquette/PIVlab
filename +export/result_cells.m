function [S, W] = result_cells(resultslist, frames)
%The vector data of the MAT file and workspace exports, one cell per frame of frames (column):
%S: x, y, u/v/typevector original, filtered and smoothed (in this order), calibrated
%   (velocity, or standard deviation / TKE of temporal statistics, gui.frame_factors).
%W: stereo-PIV: w_original, w_filtered, w_smoothed (units like u); empty struct in 2D.
%   w is computed from the validated results of both cameras: original = filtered.
if size(resultslist,1)< 11
	resultslist{11,size(resultslist,2)}=[]; %make sure resultslist has cells for all params
end
empty=cell(numel(frames),1);
S=struct('x',{empty},'y',{empty},'u_original',{empty},'v_original',{empty},'typevector_original',{empty}, ...
	'u_filtered',{empty},'v_filtered',{empty},'typevector_filtered',{empty},'u_smoothed',{empty},'v_smoothed',{empty});
stereo_mode=isequal(gui.retr('stereomode'),1);
if stereo_mode
	W=struct('w_original',{empty},'w_filtered',{empty},'w_smoothed',{empty});
else
	W=struct();
end
for i=1:numel(frames)
	f=frames(i);
	fac=gui.frame_factors(f);
	[S.x{i},S.y{i}]=calibrate.xy (resultslist{1,f},resultslist{2,f});
	S.u_original{i}=resultslist{3,f}*fac.u;
	S.v_original{i}=resultslist{4,f}*fac.v;
	S.typevector_original{i}=resultslist{5,f};
	S.u_filtered{i}=resultslist{7,f}*fac.u;
	S.v_filtered{i}=resultslist{8,f}*fac.v;
	S.typevector_filtered{i}=resultslist{9,f};
	S.u_smoothed{i}=resultslist{10,f}*fac.u;
	S.v_smoothed{i}=resultslist{11,f}*fac.v;
	if stereo_mode
		W.w_original{i}=stereo.w_of_frame(f,false,resultslist)*fac.w;
		W.w_filtered{i}=W.w_original{i};
		if size(resultslist,1)>=17
			W.w_smoothed{i}=resultslist{17,f}*fac.w;
		end
	end
end
