function res = helper_truth_calibrate(res, C)
%HELPER_TRUTH_CALIBRATE Apply the calibration of a truth case (helper_truth_cases) with pivlab.toMetric.
%   Uncalibrated cases with flipped axes use the Settings route of pivlab.toMetric (calxy = 1,
%   calu / calv = +-1), like the PIVlab window does without a calibration.
xnames = ["right", "left"];
ynames = ["down", "up"];
switch C.kind
    case 'px'
        s = pivlab.defaults();
        sc = s.calibration;
        sc.calxy = 1;
        sc.calu = C.sx;
        sc.calv = -C.sy;              % v inside PIVlab is positive downward
        sc.offset_x_true = 0;
        sc.offset_y_true = 0;
        sc.x_axis_direction = C.xdir;
        sc.y_axis_direction = C.ydir;
        sc.realdist = 1;
        sc.time_inp = 1;
        sc.pointscali = [];
        sc.displacement_only = false;
        s.calibration = sc;
        res = pivlab.toMetric(res, Settings=s, Verbose=false);
    case {'disp', 'ms'}
        res = pivlab.toMetric(res, DeltaT=C.dt, PxPerMeter=C.px_per_m, XAxis=xnames(C.xdir), ...
            YAxis=ynames(C.ydir), Verbose=false);
    case 'ref'
        res = pivlab.toMetric(res, DeltaT=C.dt, ReferenceDistance=C.ref, XAxis=xnames(C.xdir), ...
            YAxis=ynames(C.ydir), Verbose=false);
    case 'stereo'
        % stereo-PIV result: DeltaT only, the scale comes from the stereo calibration
        res = pivlab.toMetric(res, DeltaT=C.dt, XAxis=xnames(C.xdir), YAxis=ynames(C.ydir), Verbose=false);
    case 'orig'
        res = pivlab.toMetric(res, DeltaT=C.dt, PxPerMeter=C.px_per_m, Origin=C.origin, ...
            XAxis=xnames(C.xdir), YAxis=ynames(C.ydir), Verbose=false);
    otherwise
        error('helper_truth_calibrate: unknown kind "%s"', C.kind);
end
end
