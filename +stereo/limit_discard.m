function discard = limit_discard(only_frames)
%LIMIT_DISCARD Vectors outside the velocity limits of the 3D result (stereo-PIV vector validation).
%   discard = stereo.limit_discard             all image pairs
%   discard = stereo.limit_discard(frames)     only these image pairs (the others stay empty)
% The velocity limits (rectangle, freehand) and the velocity magnitude limits of the vector validation are
% drawn on the 3D result, so they are tested on U, V (and the 3D magnitude sqrt(U^2 + V^2 + W^2)) of the
% raw 2D results of both cameras (stereo.reconstruct_results(true)), with the same rules as in 2D
% (validate.filtervectors_all_parallel). discard{i} is a logical map of the vectors of image pair i that are
% outside the limits; stereo.per_camera discards them in both cameras (stereo.camera_limits), then each
% camera is validated as in 2D. discard = [] if no limit is active.
if nargin < 1
    only_frames = [];
end
discard = [];
handles = gui.gethand;
velrect = gui.retr('velrect');
velrect_freehand = gui.retr('velrect_freehand');
do_notch_filter = get(handles.notch_enable, 'Value') == 1;
if isempty(velrect) && isempty(velrect_freehand) && ~do_notch_filter
    return
end
resultslist = stereo.reconstruct_results(true, only_frames);
discard = cell(1, size(resultslist, 2));
if isempty(resultslist)
    return
end
calu = gui.retr('calu');
calv = gui.retr('calv');
roi_freehand = [];
if ~isempty(velrect_freehand)
    roi_freehand = images.roi.Freehand('Position', velrect_freehand);
end
notch_limits = [];
if do_notch_filter
    notch_limits = [str2double(get(handles.notch_L_thresh, 'String')), str2double(get(handles.notch_H_thresh, 'String'))];
end
for i = 1:size(resultslist, 2)
    if isempty(resultslist{1, i})
        continue
    end
    discard{i} = stereo.limit_test(resultslist{3, i} * calu, resultslist{4, i} * calv, ...
        resultslist{16, i} * abs(calu), velrect, roi_freehand, notch_limits); % |calu|: an axis flip does not flip w
end
end
