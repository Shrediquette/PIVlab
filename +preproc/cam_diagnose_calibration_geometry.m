function diag = cam_diagnose_calibration_geometry(imagePoints, worldPoints, imageSize)
% CAM_DIAGNOSE_CALIBRATION_GEOMETRY  Explain why a ChArUco calibration set is bad.
%
%   diag = cam_diagnose_calibration_geometry(imagePoints, worldPoints, imageSize)
%
% Read-only diagnostic. Distinguishes the two real causes of a failed/poor camera
% calibration and returns an actionable message:
%   'detection' - too few ChArUco markers detected in one or more images.
%   'diversity' - markers fine, but the board orientations do not constrain the
%                 camera (tilted about a single axis and/or barely rolled). Names
%                 which of yaw (left/right tilt), pitch (up/down tilt) and roll
%                 (in-plane rotation) is missing.
%   'unknown'   - neither check is conclusive.
%
% It does NOT need calibrated intrinsics: relative board pose is recovered per view
% from a homography decomposed with an approximate pinhole K0, which is robust enough
% to measure the *spread* of orientations across the set.
%
% Inputs:
%   imagePoints - M x 2 x numViews array of detected corner coordinates (NaN = missing)
%   worldPoints - M x 2 planar board coordinates (mm)
%   imageSize   - [height width] of the calibration images
%
% Output struct fields: primaryCause, message, validPerView, weakViews,
%   yawSpread, pitchSpread, rollSpread, exercised (logical [yaw pitch roll]).

% ---- Tunable thresholds (validated against the PIVlab example sets) ----
% Calibration is well-conditioned when the board is tilted about BOTH image axes.
% Degeneracy shows up as tilt concentrated on a single axis, i.e. a large *imbalance*
% between the yaw and pitch spreads rather than a small absolute spread. So an axis
% counts as "exercised" only if its board-normal spread clears an absolute floor AND
% is not dwarfed by the other axis. Reference: bad TIF set yaw=0.23 pitch=0.95 (4:1,
% degenerate); good JPG set yaw=0.78 pitch=0.68 (balanced, fine).
NORMAL_FLOOR     = 0.15;   % minimum board-normal spread (~+/-9 deg tilt) for an axis to count at all
NORMAL_BALANCE   = 0.40;   % ...and at least this fraction of the dominant axis' spread
ROLL_SPREAD_THRESH = 15;   % degrees of in-plane rotation spread to call roll "exercised"
WEAK_VIEW_FRACTION = 0.25; % a view is "weak" below this fraction of expected corners
MIN_WEAK_POINTS    = 6;    % ...but never flag a view that still has at least this many points

imgHeight = imageSize(1);
imgWidth  = imageSize(2);
numViews  = size(imagePoints, 3);
expectedCorners = size(worldPoints, 1);   % (rows-1)*(cols-1)

% ---- 1. Detection check ----
validPerView = squeeze(sum(~isnan(imagePoints(:,1,:)) & ~isnan(imagePoints(:,2,:)), 1));
validPerView = validPerView(:)';
weakThresh   = max(MIN_WEAK_POINTS, WEAK_VIEW_FRACTION * expectedCorners);
weakViews    = find(validPerView < weakThresh);
nUsable      = numViews - numel(weakViews);

diag = struct();
diag.validPerView = validPerView;
diag.weakViews    = weakViews;

% Detection is the primary problem when most views are weak, or too few usable
% views remain for any calibration.
if numel(weakViews) > numViews/2 || nUsable < 3
    diag.primaryCause = 'detection';
    diag.message = detectionMessage(weakViews, validPerView, expectedCorners);
    diag.yawSpread = NaN; diag.pitchSpread = NaN; diag.rollSpread = NaN;
    diag.exercised = [false false false];
    return
end

% ---- 2. Pose-diversity check (only on views with enough points) ----
f0 = 1.2 * imgWidth;
K0 = [f0 0 imgWidth/2; 0 f0 imgHeight/2; 0 0 1];
normals = []; rolls = [];
for v = 1:numViews
    x = imagePoints(:,1,v); y = imagePoints(:,2,v);
    m = ~isnan(x) & ~isnan(y);
    if sum(m) < 4, continue, end
    try
        H = fitgeotform2d([worldPoints(m,1) worldPoints(m,2)], [x(m) y(m)], 'projective').A;
    catch
        continue
    end
    Mtx = K0 \ H;
    lam = 1 / norm(Mtx(:,1));
    r1 = Mtx(:,1) * lam; r2 = Mtx(:,2) * lam; r3 = cross(r1, r2);
    R = [r1 r2 r3];
    [U,~,Vt] = svd(R); R = U * Vt';
    if R(3,3) < 0, R = -R; end          % ensure board normal faces the camera (+z)
    normals(end+1,:) = R(:,3)';                       %#ok<AGROW>
    rolls(end+1,1)   = atan2d(R(2,1), R(1,1));        %#ok<AGROW>
end

if size(normals,1) < 2
    diag.primaryCause = 'unknown';
    diag.message = genericMessage();
    diag.yawSpread = NaN; diag.pitchSpread = NaN; diag.rollSpread = NaN;
    diag.exercised = [false false false];
    return
end

yawSpread   = max(normals(:,1)) - min(normals(:,1));   % left/right tilt
pitchSpread = max(normals(:,2)) - min(normals(:,2));   % up/down tilt
rollSpread  = max(rolls) - min(rolls);                 % in-plane rotation

% An axis is "exercised" only if it clears the absolute floor AND is not dwarfed by
% the dominant tilt axis (catches single-axis-concentrated tilt).
tiltGate = max(NORMAL_FLOOR, NORMAL_BALANCE * max(yawSpread, pitchSpread));
exercised = [yawSpread   >= tiltGate, ...
             pitchSpread >= tiltGate, ...
             rollSpread  >= ROLL_SPREAD_THRESH];

diag.yawSpread = yawSpread; diag.pitchSpread = pitchSpread; diag.rollSpread = rollSpread;
diag.exercised = exercised;

% Calibration needs tilt about BOTH image axes. If fewer than two of {yaw,pitch}
% are exercised, the set is under-constrained.
if sum(exercised(1:2)) < 2
    diag.primaryCause = 'diversity';
    diag.message = diversityMessage(exercised);
else
    diag.primaryCause = 'unknown';
    diag.message = genericMessage();
end
end

% ============================================================
function msg = detectionMessage(weakViews, validPerView, expectedCorners)
list = strjoin(arrayfun(@(i) sprintf('#%d (%d/%d)', i, validPerView(i), expectedCorners), ...
    weakViews, 'UniformOutput', false), ', ');
msg = { 'Camera calibration failed: too few ChArUco markers were detected.'; '';
    ['Weak images: ' list '.']; '';
    ['Check focus, lighting and glare, and that the board parameters (rows, columns, ' ...
     'checker/marker size, dictionary and origin colour) match the printed board. ' ...
     'Then remove the weak images or re-capture them.'] };
end

% ============================================================
function msg = diversityMessage(exercised)
% exercised = [yaw pitch roll]
missing = {};
if ~exercised(1), missing{end+1} = 'left/right tilt'; end
if ~exercised(2), missing{end+1} = 'up/down tilt';    end
if ~exercised(3), missing{end+1} = 'in-plane rotation (roll)'; end
missingStr = strjoin(missing, ', ');
msg = { 'Camera calibration failed: the images do not constrain the camera enough.'; '';
    ['The board orientations lack variation in: ' missingStr '.']; '';
    ['Re-capture so that across the set you tilt the board about BOTH axes (rotate the ' ...
     'left/right edges toward the camera AND the top/bottom edges) and add some in-plane ' ...
     'rotation. A few well-varied images often calibrate better than many similar ones.'] };
end

% ============================================================
function msg = genericMessage()
msg = { 'Camera calibration failed to produce a valid result.'; '';
    ['Try re-capturing the board with more varied orientations (tilt about both axes ' ...
     'and add in-plane rotation), better lighting/focus, or a smaller well-varied subset ' ...
     'of images.'] };
end
