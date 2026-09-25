function PIVlab_capture_count_preview_frames(~,event,himage)
%PIVlab_capture_count_preview_frames  Preview callback that displays AND counts the camera frames.
%
%   setappdata(himage,'frames_shown',0);
%   setappdata(himage,'UpdatePreviewWindowFcn',@PIVlab_capture_count_preview_frames);
%   preview(vid,himage)
%
%   preview() first shows a placeholder image until the first camera frame arrives (can take > 1 s).
%   Its pixel values depend on adaptor and pixel format, so it cannot be recognised reliably from the
%   image content. This callback is only called for REAL frames, so getappdata(himage,'frames_shown')
%   tells the calibration drivers when a real camera image is displayed (single-image grab, ROI selection).
set(himage,'CData',event.Data);
setappdata(himage,'frames_shown',getappdata(himage,'frames_shown')+1);
