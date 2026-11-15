function C = helper_truth_cases(which)
%HELPER_TRUTH_CASES Axis directions and calibrations of the truth-based tests (test_truth_*).
%   C = helper_truth_cases()         all cases (4 axis settings x 5 calibrations)
%   C = helper_truth_cases('short')  4 axis settings x 2 calibrations (px/frame and m/s with origin)
%
%   Each element is one case. The expected factors are written out here by hand (not taken from
%   calibrate.*), so that the tests check PIVlab's calibration code:
%   C(k).name      text for messages
%   C(k).xdir      1 = x to the right, 2 = x to the left   (GUI popup x_axis_direction)
%   C(k).ydir      1 = y downward, 2 = y upward            (GUI popup y_axis_direction)
%   C(k).kind      'px'   uncalibrated (px, px/frame)
%                  'disp' spatial calibration only, dt = 0 (m, m/frame)
%                  'ms'   spatial calibration and time step (m, m/s)
%                  'ref'  like 'ms', scale from a reference distance [px m]
%                  'orig' like 'ms', with a user-defined origin (pixel position of x = 0, y = 0)
%   C(k).dt        time step in s (0 for 'disp', [] for 'px')
%   C(k).px_per_m  image scale (px per m), [] for 'px'
%   C(k).ref       reference distance [px m] ('ref' only)
%   C(k).origin    [x0 y0] pixel position of the origin, [] = default corner
%   C(k).calxy     m per px (1 for 'px')
%   C(k).t         s per frame for the velocity units (1 for 'px' and 'disp')
%   C(k).sx, sy    +1 if x points right / y points up on the screen, else -1
%   C(k).units     expected res.units
if nargin < 1
    which = 'all';
end
kinds = {'px', 'disp', 'ms', 'ref', 'orig'};
if strcmp(which, 'short')
    kinds = {'px', 'orig'};
end
xnames = {'right', 'left'};
ynames = {'down', 'up'};
C = struct([]);
k = 0;
for i = 1:numel(kinds)
    for xd = 1:2
        for yd = 1:2
            k = k + 1;
            c = struct();
            c.kind = kinds{i};
            c.xdir = xd;
            c.ydir = yd;
            c.dt = [];
            c.px_per_m = [];
            c.ref = [];
            c.origin = [];
            switch c.kind
                case 'px'
                    c.calxy = 1;
                    c.t = 1;
                    c.units = "px/frame";
                case 'disp'
                    c.dt = 0;
                    c.px_per_m = 2500;
                    c.calxy = 1 / 2500;
                    c.t = 1;
                    c.units = "m/frame";
                case 'ms'
                    c.dt = 0.0013;
                    c.px_per_m = 4321.7;
                    c.calxy = 1 / 4321.7;
                    c.t = 0.0013;
                    c.units = "m/s";
                case 'ref'
                    c.dt = 0.002;
                    c.ref = [517.3 0.0421];
                    c.calxy = 0.0421 / 517.3;
                    c.t = 0.002;
                    c.units = "m/s";
                case 'orig'
                    c.dt = 0.0013;
                    c.px_per_m = 4321.7;
                    c.origin = [37.5 251.25];
                    c.calxy = 1 / 4321.7;
                    c.t = 0.0013;
                    c.units = "m/s";
            end
            c.sx = 1;
            if xd == 2
                c.sx = -1;
            end
            c.sy = -1;
            if yd == 2
                c.sy = 1;
            end
            c.name = sprintf('%s, x %s, y %s', c.kind, xnames{xd}, ynames{yd});
            if k == 1
                C = c;
            else
                C(k) = c;
            end
        end
    end
end
end
