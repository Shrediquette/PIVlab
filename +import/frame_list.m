function src = frame_list(s, sel)
%FRAME_LIST Frame list struct for import.read_frame / import.read_raw_frame from data that has one.
%   src = import.frame_list(s)        s: any struct with filepath, framenum, framepart (an image set of the API,
%                                     the per-camera state of the GUI, a frame list); video fields are kept
%   src = import.frame_list(s, sel)   only the frames sel (indices into the frame list)
src = struct('filepath', {s.filepath}, 'framenum', s.framenum, 'framepart', s.framepart);
if isfield(s, 'video_reader_object')
    src.video_reader_object = s.video_reader_object;
end
if isfield(s, 'video_frame_selection')
    src.video_frame_selection = s.video_frame_selection;
end
if nargin < 2
    return
end
src.filepath = src.filepath(sel);
src.framenum = src.framenum(sel);
if ~isempty(src.framepart)
    src.framepart = src.framepart(sel, :);
end
if isfield(src, 'video_frame_selection') && ~isempty(src.video_frame_selection)
    src.video_frame_selection = src.video_frame_selection(sel);
end
end
