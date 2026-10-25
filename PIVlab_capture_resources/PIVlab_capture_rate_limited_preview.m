function PIVlab_capture_rate_limited_preview(~, event, himage)
%PIVlab_capture_rate_limited_preview  Preview callback that displays the camera frames at a limited rate and counts them.
%
%   setappdata(himage,'frames_shown',0);
%   setappdata(himage,'max_display_rate',10);   % frames per second that are drawn (default 10)
%   setappdata(himage,'UpdatePreviewWindowFcn',@PIVlab_capture_rate_limited_preview);
%   preview(vid,himage)
%
%   imaq calls this function for every camera frame. Drawing every frame of a fast camera (or of two
%   cameras) in the PIVlab window costs a lot of CPU time and can make the cameras skip frames, so a frame
%   is only drawn when 1/max_display_rate seconds have passed since the last one (acquisition.show_frame,
%   full resolution; the full frame is also kept for the overlays). The first frame is always drawn.
%   frames_shown counts the real camera frames, like PIVlab_capture_count_preview_frames: when it is >= 1,
%   a real camera image is displayed (the preview placeholder is not counted).
if ~isvalid(himage)
	return
end
rate = getappdata(himage,'max_display_rate');
if isempty(rate)
	rate = 10;
end
last_display = getappdata(himage,'last_display');
if isempty(last_display) || toc(last_display) >= 1/rate
	acquisition.show_frame(himage, event.Data, 1);
	setappdata(himage,'last_display',tic);
end
setappdata(himage,'frames_shown',getappdata(himage,'frames_shown')+1);
