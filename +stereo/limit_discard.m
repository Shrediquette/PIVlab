function discard = limit_discard(only_frames)
%LIMIT_DISCARD Vectors outside the velocity limits of the 3D result (stereo-PIV vector validation).
%   discard = stereo.limit_discard             all image pairs
%   discard = stereo.limit_discard(frames)     only these image pairs (the others stay empty)
% The velocity limits (rectangle, freehand) and the velocity magnitude limits of the vector validation are
% drawn on the 3D result, so they are tested on U, V (and the 3D magnitude sqrt(U^2 + V^2 + W^2)) of the
% raw 2D results of both cameras (stereo.reconstruct_results(true)), with the same rules as in 2D
% (validate.filtervectors_all_parallel). The filters of the stereo based validation panel (reconstruction
% residual, local median of W, W limits) are tested on the same 3D result. discard{i} is a logical map of the
% vectors of image pair i that are rejected; stereo.per_camera discards them in both cameras
% (stereo.camera_limits), then each camera is validated as in 2D. discard = [] if no limit is active.
if nargin < 1
    only_frames = [];
end
discard = [];
handles = gui.gethand;
velrect = gui.retr('velrect');
velrect_freehand = gui.retr('velrect_freehand');
do_notch_filter = get(handles.notch_enable, 'Value') == 1;
stereo_filters = panel_filters(handles);
if isempty(velrect) && isempty(velrect_freehand) && ~do_notch_filter && isempty(stereo_filters.residual_thresh) ...
        && isempty(stereo_filters.w_median_thresh) && isempty(stereo_filters.w_limits)
    return
end
[resultslist, stereo_vel] = stereo.reconstruct_results(true, only_frames);
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
        resultslist{16, i} * calibrate.w_factor(calu, calv), velrect, roi_freehand, notch_limits, ...
        stereo_vel.residual(:, :, i), resultslist{16, i}, stereo_filters); % w along z = x cross y
end
end

function s = panel_filters(handles)
% the filters of the stereo based validation panel that are ticked ([] = off)
s.residual_thresh = [];
s.w_median_thresh = [];
s.w_limits = [];
if get(handles.residual_enable, 'Value') == 1
    s.residual_thresh = str2double(get(handles.residual_thresh, 'String'));
end
if get(handles.w_median_enable, 'Value') == 1
    s.w_median_thresh = str2double(get(handles.w_median_thresh, 'String'));
end
if get(handles.w_limit_enable, 'Value') == 1
    s.w_limits = sort([str2double(get(handles.w_limit_min, 'String')), str2double(get(handles.w_limit_max, 'String'))]);
end
end
