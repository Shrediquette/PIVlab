function u = camera_use(centre, views, opts)
%CAMERA_USE What two cameras are used for: stereo-PIV or a larger field of view (automatic choice).
%   u = stereo.camera_use(centre, views)
%   u = stereo.camera_use(centre, views, opts)
%   centre   2x3, camera centres in board coordinates [mm] (calib.centre)
%   views    1x2 cell, polyshape of the view of camera 1 and 2 on the board (stereo.view_polygons)
%   opts     stereo.defaults().calibration (StereoMinOverlap [%], StereoMinAngle [deg])
%   u.use       "stereo" or "fov"
%   u.overlap   overlap of the views [% of the smaller view]
%   u.angle     angle between the lines of sight of both cameras to the centre of the overlap [deg]
%               (as in stereo.geometry_report; NaN without overlap)
%   u.reason    one line for the report
% Stereo-PIV needs both: the views overlap for the most part, and the cameras look at the overlap from
% clearly different directions (else w can not be measured). Everything else gives a larger field of view:
% cameras side by side with a small overlap (they also see the seam at opposite angles, so the angle alone
% does not decide), cameras without overlap, or parallel cameras with a large overlap (no useful w). A
% translation stereo set-up (parallel cameras, shifted, large overlap) is stereo through the angle of the
% lines of sight.
if nargin < 3 || isempty(opts)
    d = stereo.defaults();
    opts = d.calibration;
end
overlap = intersect(views{1}, views{2});
areas = [area(views{1}), area(views{2})];
u.overlap = 0;
u.angle = NaN;
if overlap.NumRegions > 0
    u.overlap = 100 * area(overlap) / min(areas);
    [cx, cy] = centroid(overlap);
    sight = [cx cy 0] - centre;
    sight = sight ./ vecnorm(sight, 2, 2);
    u.angle = acosd(min(1, abs(dot(sight(1, :), sight(2, :)))));
end
deg = char(176);
if u.overlap < opts.StereoMinOverlap
    u.use = "fov";
    if u.overlap == 0
        u.reason = 'The camera views do not overlap -> larger field of view (u, v)';
    else
        u.reason = sprintf('Overlap of the views %.0f %% (stereo-PIV needs %.0f %%) -> larger field of view (u, v)', ...
            u.overlap, opts.StereoMinOverlap);
    end
elseif u.angle < opts.StereoMinAngle
    u.use = "fov";
    u.reason = sprintf('Cameras look nearly parallel (%.0f%s, stereo-PIV needs %.0f%s) -> larger field of view (u, v)', ...
        u.angle, deg, opts.StereoMinAngle, deg);
else
    u.use = "stereo";
    u.reason = sprintf('Angle between the cameras %.0f%s, overlap %.0f %% -> stereo-PIV (u, v, w)', u.angle, deg, u.overlap);
end
end
