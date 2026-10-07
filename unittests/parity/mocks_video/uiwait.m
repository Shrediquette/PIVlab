function uiwait(varargin)
% Test mock for the video import dialog (import.vid_import): instead of waiting for the user,
% store the frame selection prepared by parity_run, like the "Import" button of the dialog does.
% This folder is only on the MATLAB path while the video scenario of parity_run runs.
sel = getappdata(0,'parity_video_selection');
hgui = getappdata(0,'hgui');
setappdata(hgui,'filename',sel.filename);
setappdata(hgui,'filepath',sel.filepath);
setappdata(hgui,'pathname',sel.pathname);
setappdata(hgui,'video_frame_selection',sel.video_frame_selection);
setappdata(hgui,'video_selection_done',1);
fig = getappdata(0,'fig_handle');
if ~isempty(fig) && ishghandle(fig)
    close(fig)
end
end
