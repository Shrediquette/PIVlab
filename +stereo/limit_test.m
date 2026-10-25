function out = limit_test(U, V, W, velrect, roi_freehand, notch_limits)
%LIMIT_TEST Vectors of a 3D result outside the velocity limits (shared by the GUI and the API).
%   out = stereo.limit_test(U, V, W, velrect, roi_freehand, notch_limits)
%   U, V, W        one image pair, in the units of the limits (calibrated like u, v; W with |calu|)
%   velrect        rectangle [umin vmin width height] (as postproc.PIVlab_postproc), [] = none
%   roi_freehand   freehand shape (images.roi.Freehand) in the u-v plane, [] = none; NaN vectors are not tested
%   notch_limits   [low high]: vectors with a 3D magnitude sqrt(U^2 + V^2 + W^2) between them, [] = none
%   out            logical map: true = outside the limits (discarded in both cameras, stereo.limit_discard)
out = false(size(U));
U = double(U);
V = double(V);
W = double(W);
if ~isempty(velrect)
    out = out | U < velrect(1) | U > velrect(1) + velrect(3) | V < velrect(2) | V > velrect(2) + velrect(4);
end
if ~isempty(roi_freehand)
    valid = isfinite(U) & isfinite(V);
    inside = inROI(roi_freehand, U(valid), V(valid));
    outside_map = false(size(U));
    outside_map(valid) = ~inside;
    out = out | outside_map;
end
if ~isempty(notch_limits)
    magnitude = sqrt(U .^ 2 + V .^ 2 + W .^ 2);
    out = out | (magnitude < notch_limits(2) & magnitude > notch_limits(1));
end
end
