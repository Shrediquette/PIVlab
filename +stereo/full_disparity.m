function disparity = full_disparity(calib, disparity)
%FULL_DISPARITY Add the full-size disparity maps (u_full, v_full) to a stored disparity.
%   disparity = stereo.full_disparity(calib, disparity)
% The GUI stores the disparity without the full-size maps (they are as large as the images); they are
% made again from the map on the PIV grid (stereo.disparity_field). [] stays [].
if isempty(disparity) || isfield(disparity, 'u_full')
    return
end
full = stereo.disparity_field(calib, disparity.x, disparity.y, disparity.u_mean_smooth, disparity.v_mean_smooth);
disparity.u_full = full.u_full;
disparity.v_full = full.v_full;
end
