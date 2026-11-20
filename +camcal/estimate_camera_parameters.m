function [cameraParams, imagesUsed, stats] = estimate_camera_parameters(imagePoints, worldPoints, imageSize, varargin)
%ESTIMATE_CAMERA_PARAMETERS Lens calibration of the PIVlab camera calibration panel (pure MATLAB).
%   [cameraParams, imagesUsed, stats] = camcal.estimate_camera_parameters(imagePoints, worldPoints, imageSize)
%   [...] = camcal.estimate_camera_parameters(..., initParams)   start values of a previous pass
%   [...] = camcal.estimate_camera_parameters(..., 'use_tilted_model', true)
%   [...] = camcal.estimate_camera_parameters(..., 'use_tilted_model', true, 'tilt_angle_y', deg)
%
%   imagePoints   [M x 2 x numImages] board points (NaN = not detected), worldPoints [M x 2] (mm),
%   imageSize     [rows cols]
%   initParams    cameraParameters: K, radial and tangential distortion as start values
%   'use_tilted_model'  true: tilted sensor (Scheimpflug) model, tauX and tauY estimated
%   'tilt_angle_y'      tilted model with the tilt about the vertical image axis fixed to this
%                       angle (tilt about x = 0). Both signs are calibrated; the result with the
%                       principal point closer to the image centre is kept. NaN: estimate the tilt.
%
%   cameraParams  cameraParameters (K, k1 k2, p1 p2, board poses); the tilt is not part of it
%   imagesUsed    images with at least 4 points
%   stats         ReprojectedPoints, ReprojectionErrors, MeanReprojectionError, WorldPoints,
%                 tilted_model, tilt_candidates (fixed tilt: both signs), D_full (distortion
%                 vector: [k1 k2 p1 p2], tilted model: 14 elements [k1 k2 p1 p2 0..0 tauX tauY]),
%                 K_opencv ([fx 0 cx; 0 fy cy; 0 0 1], for camcal.undistort_image)
%
%   The camera model and the calibration are those of OpenCV calibrateCamera (camcal.calibrate_camera
%   gives the same results), without OpenCV.
initParams = [];
use_tilted_model = false;
tilt_angle_y = NaN;
i = 1;
while i <= numel(varargin)
	if isa(varargin{i}, 'cameraParameters')
		initParams = varargin{i};
		i = i + 1;
	elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'use_tilted_model')
		use_tilted_model = logical(varargin{i+1});
		i = i + 2;
	elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'tilt_angle_y')
		tilt_angle_y = varargin{i+1};
		if isempty(tilt_angle_y)
			tilt_angle_y = NaN;
		end
		i = i + 2;
	else
		i = i + 1;
	end
end

disp('--camera calibration--')
fixed_tilt = use_tilted_model && ~isnan(tilt_angle_y);
if fixed_tilt
	fprintf('--Scheimpflug tilted sensor model, tilt about y fixed to +/-%.2f deg--\n', abs(tilt_angle_y));
elseif use_tilted_model
	disp('--Scheimpflug tilted sensor model enabled--')
else
	disp('--Standard distortion model--')
end

% start values of a previous pass (cameraParameters: MATLAB layout of K)
K_init = [];
D_init = [];
if ~isempty(initParams)
	Kmatlab = initParams.IntrinsicMatrix;
	K_init = [ Kmatlab(1,1)  0               Kmatlab(3,1);
		0             Kmatlab(2,2)    Kmatlab(3,2);
		0             0               1 ];
	D_init = [initParams.RadialDistortion initParams.TangentialDistortion];
end

tilt_candidates = [];
if fixed_tilt
	% standard calibration as start values, then the tilted model with tauY fixed to
	% both signs of the angle. The images cannot tell the sign: both fit equally well,
	% only the principal point moves (by about f*tan(angle)). Keep the sign that puts
	% the principal point closer to the image centre (where the optical axis of a
	% Scheimpflug adapter meets the sensor).
	opts = struct('K_init', K_init, 'D_init', D_init);
	[Kb, Db] = camcal.calibrate_camera(imagePoints, worldPoints, imageSize, opts);
	if tilt_angle_y == 0
		signs = 1;
	else
		signs = [1 -1];
	end
	% image centre in the coordinates of imagePoints (MATLAB: first pixel centre = 1)
	centre = [(imageSize(2) + 1) / 2, (imageSize(1) + 1) / 2];
	best_distance = Inf;
	for s = 1:numel(signs)
		D_start = zeros(1, 14);
		D_start(1:4) = Db(1:4);
		D_start(14) = signs(s) * deg2rad(abs(tilt_angle_y));
		opts = struct('tilted', true, 'K_init', Kb, 'D_init', D_start, 'fix_tilt', true);
		[Ks, Ds, rvecs_s, tvecs_s] = camcal.calibrate_camera(imagePoints, worldPoints, imageSize, opts);
		distance = norm([Ks(1,3) Ks(2,3)] - centre);
		tilt_candidates(s).tilt_angle_y = rad2deg(D_start(14)); %#ok<AGROW>
		tilt_candidates(s).principal_point = [Ks(1,3) Ks(2,3)]; %#ok<AGROW>
		tilt_candidates(s).distance_to_centre = distance; %#ok<AGROW>
		fprintf('  tilt %+.2f deg: principal point [%.0f %.0f], %.0f px from image centre\n', ...
			rad2deg(D_start(14)), Ks(1,3), Ks(2,3), distance);
		if distance < best_distance
			best_distance = distance;
			K2 = Ks;
			D2 = Ds;
			rvecs2 = rvecs_s;
			tvecs2 = tvecs_s;
		end
	end
	fprintf('  using tilt %+.2f deg\n', rad2deg(D2(14)));
else
	opts = struct('tilted', use_tilted_model, 'K_init', K_init, 'D_init', D_init);
	[K2, D2, rvecs2, tvecs2] = camcal.calibrate_camera(imagePoints, worldPoints, imageSize, opts);
	if ~use_tilted_model
		D2 = D2(1:4); % standard model: [k1 k2 p1 p2]
	end
end

% ---- Validate the solution before it propagates further
% An ill-conditioned image set (e.g. boards tilted about a single axis) can give a physically
% invalid result: the principal point lands outside the image and/or the focal length runs
% away. Raise a clear, identifiable error so the caller can show actionable guidance.
imgHeight = imageSize(1);
imgWidth  = imageSize(2);
cx = K2(1,3); cy = K2(2,3);
fx = K2(1,1); fy = K2(2,2);
focalLimit = 50 * max(imgWidth, imgHeight);   % generous; never rejects a real lens
if cx < 0 || cx >= imgWidth || cy < 0 || cy >= imgHeight || ...
		fx <= 0 || fy <= 0 || fx > focalLimit || fy > focalLimit
	error('PIVlab:calibration:degenerate', ...
		['Camera calibration did not converge to a physically valid solution ' ...
		'(principal point [%.0f %.0f] outside image [%d %d], or focal length ' ...
		'[%.0f %.0f] implausible). The calibration images do not constrain the ' ...
		'camera enough.'], cx, cy, imgWidth, imgHeight, fx, fy);
end

% ---- K in MATLAB layout
Kmat = [ K2(1,1)  0         0;
	0        K2(2,2)   0;
	K2(1,3)  K2(2,3)   1 ];

cameraParams = cameraParameters( ...
	'IntrinsicMatrix', Kmat, ...
	'RadialDistortion', D2(1:2), ...
	'TangentialDistortion', D2(3:4), ...
	'RotationVectors', rvecs2, ...
	'WorldPoints', worldPoints, ...
	'TranslationVectors', tvecs2, ...
	'ImageSize', imageSize);

% ---- Reprojection with the full model (incl. tauX, tauY; MATLAB's worldToImage has no
% tilted sensor)
K_cv = [ K2(1,1)  0         K2(1,3);
	0         K2(2,2)  K2(2,3);
	0         0        1       ];
numImages = size(imagePoints,3);
ReprojectedPoints = nan(size(imagePoints));
ReprojectionErrors = nan(size(imagePoints));
imagesUsed = false(numImages,1);
allErrors = [];
validIndex = 0;
for v = 1:numImages
	validMask = ~isnan(imagePoints(:,1,v)) & ~isnan(imagePoints(:,2,v));
	if sum(validMask) < 4
		continue
	end
	validIndex = validIndex + 1;
	imagesUsed(v) = true;
	wp = worldPoints(validMask,:);
	wp3 = [wp zeros(size(wp,1),1)];
	proj = camcal.project_points(wp3, rvecs2(validIndex,:), tvecs2(validIndex,:), K_cv, D2);
	ReprojectedPoints(validMask,:,v) = proj;
	err = imagePoints(validMask,:,v) - proj;
	ReprojectionErrors(validMask,:,v) = err;
	allErrors = [allErrors; sqrt(sum(err.^2,2))]; %#ok<AGROW>
end

stats.ReprojectedPoints     = ReprojectedPoints;
stats.ReprojectionErrors    = ReprojectionErrors;
stats.MeanReprojectionError = mean(allErrors);
stats.WorldPoints           = worldPoints;
stats.tilted_model          = use_tilted_model;
stats.tilt_candidates       = tilt_candidates; % fixed tilt: both signs (angle, principal point)
stats.D_full                = D2;   % distortion vector (4 or 14 elements)
stats.K_opencv              = K_cv; % K in OpenCV layout, for camcal.undistort_image
end
