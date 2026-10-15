function [u, v, u2, v2, apply_limits] = camera_limits(frame, u, v, u2, v2)
%CAMERA_LIMITS Velocity limits in the vector validation of one camera (stereo-PIV).
%   [u, v, u2, v2, apply_limits] = stereo.camera_limits(frame, u, v, u2, v2)
% Called by the vector validation (validate.filtervectors, validate.apply_filter_all_Callback) just before
% validate.filtervectors_all_parallel. In 2D (and for the 2D check before the stereo calibration) nothing
% changes and apply_limits is true. In the camera loop of stereo.per_camera the velocity limits and the
% magnitude limits were already tested on the 3D result (stereo.limit_discard): the vectors outside them are
% discarded here (NaN, as the limit filters do in 2D) and apply_limits is false, so the caller does not test
% the limits on the 2D displacement of the camera again. The second correlation peak (u2, v2) of a discarded
% vector is not used either: it could only be tested against the limits with both cameras.
apply_limits = true;
if ~isequal(gui.retr('stereo_camera_loop'), 1)
    return
end
apply_limits = false;
discard = gui.retr('stereo_limit_discard');
if frame > numel(discard) || isempty(discard{frame}) || ~isequal(size(discard{frame}), size(u))
    return
end
u(discard{frame}) = NaN;
v(discard{frame}) = NaN;
if isequal(size(u2), size(u))
    u2(discard{frame}) = NaN;
    v2(discard{frame}) = NaN;
end
end
