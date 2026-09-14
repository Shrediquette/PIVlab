function PIVlab_capture_OPTOcam_20_9_preview_update(~, event, himage)
%PIVlab_capture_OPTOcam_20_9_preview_update  Preview callback for the OPTOcam 20/9 double-frame capture.
%
%   Installed with setappdata(himage,'UpdatePreviewWindowFcn',@PIVlab_capture_OPTOcam_20_9_preview_update)
%   before preview() is called, so imaq hands EVERY preview frame to this function instead of
%   writing it into the image directly.
%
%   The sensor delivers the frames as A,B,A,B,... Frame B has a long, fixed exposure, so with
%   ambient light it is much brighter than frame A and the preview would flicker. Like the pco
%   driver, only frame A is shown (frame B when the A/B toggle of the main GUI is set to B).
%   A and B are told apart by their mean brightness (the preview drops frames when the GUI is
%   slow, so counting frames would not work). When both look alike (dark room, laser only)
%   every frame is shown - there is nothing to flicker then.

ab_ratio   = 1.5;   %A and B are told apart when mean(B) > ab_ratio * mean(A)
sub        = 8;     %subsampling for the mean brightness (speed)
n_history  = 8;     %frames kept for the dark/bright estimate (= 4 image pairs)

if ~isvalid(himage)
	return
end
frame = event.Data;
m = mean(frame(1:sub:end,1:sub:end),'all');

%% classify the frame as A (dark) or B (bright) from the recent brightness history
state = getappdata(himage,'OPTOcam_20_9_ab_state');
if isempty(state)
	state.means = m;
else
	state.means = [state.means(max(1,end-n_history+2):end) m];
end
lo = min(state.means);
hi = max(state.means);
if numel(state.means) >= 2 && hi > ab_ratio*lo
	is_bright = m > (lo+hi)/2;      %frame B
	ab_distinguishable = true;
else
	is_bright = false;              %A and B look alike: show everything
	ab_distinguishable = false;
end

%% show frame A, or frame B when the main GUI's A/B toggle is on B
hgui = getappdata(0,'hgui');
toggler = getappdata(hgui,'toggler');
if isempty(toggler)
	toggler = 0;
end
show_bright = toggler ~= 0;
if ~ab_distinguishable || is_bright == show_bright
	set(himage,'CData',frame);
end
setappdata(himage,'OPTOcam_20_9_ab_state',state);
