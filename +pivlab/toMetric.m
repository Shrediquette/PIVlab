function res = toMetric(res, opts)
%TOMETRIC Convert positions and velocities from pixels to metres (PIVlab "Calibration").
%   res = pivlab.toMetric(res, DeltaT=dt, PxPerMeter=scale)
%     dt     time between the two images of a pair in seconds (0: displacements in m/frame)
%     scale  image scale in pixels per metre (from a calibration image)
%   Afterwards res.x and res.y are in m, res.u and res.v in m/s, res.units is "m/s".
%
%   res = pivlab.toMetric(res, Settings=s) uses the calibration stored in a PIVlab session or
%   settings file (s = pivlab.loadSettings(file)).
%
%   Name=value options
%   DeltaT          time between the images in s
%   PxPerMeter      image scale in px/m
%   ReferenceDistance  alternative to PxPerMeter: [distance_px distance_m], e.g. a ruler in
%                   the calibration image that is 512.3 px long and 0.05 m long: [512.3 0.05]
%   Origin          pixel position [x y] of the coordinate origin (default: top left image corner)
%   XAxis           "right" (default) or "left": direction in which x increases
%   YAxis           "down" (default, image convention) or "up": direction in which y increases
%   Settings        settings struct from pivlab.loadSettings (uses its calibration)
%
%   The conversion can be repeated: it always starts from the pixel data in res.px.
%
%   Example
%       res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234, YAxis="up");
%
%   See also pivlab.filter, pivlab.derive, calibrate.compute_calibration
arguments
    res (1,1) struct
    opts.DeltaT = []
    opts.PxPerMeter = []
    opts.ReferenceDistance = []
    opts.Origin = []
    opts.XAxis {mustBeTextScalar} = "right"
    opts.YAxis {mustBeTextScalar} = "down"
    opts.Settings struct = struct()
end
has_scale = ~isempty(opts.PxPerMeter) || ~isempty(opts.ReferenceDistance);
if ~has_scale && isempty(opts.DeltaT)
    % calibration from Settings
    if isempty(fieldnames(opts.Settings))
        error('pivlab:toMetric:noCalibration', ...
            'Specify DeltaT and PxPerMeter (or ReferenceDistance), or Settings from pivlab.loadSettings.');
    end
    sc = opts.Settings.calibration;
    cal = struct('calxy',sc.calxy,'calu',sc.calu,'calv',sc.calv, ...
        'offset_x_true',sc.offset_x_true,'offset_y_true',sc.offset_y_true, ...
        'displacement_only',sc.displacement_only, ...
        'x_axis_direction',sc.x_axis_direction,'y_axis_direction',sc.y_axis_direction);
    realdist = sc.realdist; time_inp = sc.time_inp; pointscali = sc.pointscali;
else
    if ~has_scale || isempty(opts.DeltaT)
        error('pivlab:toMetric:missing','Both DeltaT and PxPerMeter (or ReferenceDistance) are needed.');
    end
    if ~isempty(opts.ReferenceDistance)
        dist_px = opts.ReferenceDistance(1);
        realdist = opts.ReferenceDistance(2)*1000;   % mm, as in the GUI
    else
        dist_px = opts.PxPerMeter;
        realdist = 1000;                             % 1 m = PxPerMeter px
    end
    pointscali = [0 0; dist_px 0];
    time_inp = opts.DeltaT*1000;                     % ms, as in the GUI
    xdir = 1 + double(strcmpi(opts.XAxis,"left"));
    ydir = 1 + double(strcmpi(opts.YAxis,"up"));
    offx = []; offy = [];
    if ~isempty(opts.Origin)
        offx = [opts.Origin(1) opts.Origin(2) 0];
        offy = [opts.Origin(1) opts.Origin(2) 0];
    end
    cal = calibrate.compute_calibration(pointscali, realdist, time_inp, xdir, ydir, offx, offy, res.images.imageSize);
end
cal.realdist = realdist;
cal.time_inp = time_inp;
cal.pointscali = pointscali;
cal.displacement_only = logical(cal.displacement_only);
res.calibration = orderfields_like(cal, res.calibration);
res.derived = struct();
res = refresh_units(res);
fprintf('Calibration: %.6g m/px, units are now %s.\n', cal.calxy, res.units);
end

function c = orderfields_like(c, ref)
f = fieldnames(ref);
for k = 1:numel(f)
    if ~isfield(c, f{k}), c.(f{k}) = ref.(f{k}); end
end
c = orderfields(c, ref);
end
