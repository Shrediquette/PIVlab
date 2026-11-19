function [cameraParams, imagesUsed, stats] = ...
	pivlab_estimateCameraParameters(imagePoints, worldPoints, imageSize, varargin)

if isdeployed %run this only in non-deployed version
	useopencv=0;
else
	useopencv=1;
end
useopencv=1;

% ---- Parse optional arguments from varargin
% Supported optional args (any order):
%   cameraParameters object  -> initial guess for refinement pass
%   'use_tilted_model', true/false -> enable Scheimpflug tilted sensor model
%   'tilt_angle_y', degrees -> tilted model with the sensor tilt about the vertical image
%       axis fixed to this angle (tilt about x = 0). Both signs are calibrated; the result
%       with the principal point closer to the image centre is kept. NaN: estimate the tilt.
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

% ============================================================
% DESKTOP MATLAB VERSION
% ============================================================
if useopencv==0 %run this only in non-deployed version
	disp('--Matlab camera estimation--')
	if nargin == 4
		initParams = varargin{1};
		cameraParams = estimateCameraParameters( ...
			imagePoints, worldPoints, ...
			'EstimateSkew', false, ...
			'EstimateTangentialDistortion', true, ...
			'NumRadialDistortionCoefficients', 2, ...
			'WorldUnits', 'millimeters', ...
			'InitialIntrinsicMatrix', initParams.IntrinsicMatrix, ...
			'InitialRadialDistortion', initParams.RadialDistortion, ...
			'ImageSize', imageSize);
	else
		cameraParams = estimateCameraParameters( ...
			imagePoints, worldPoints, ...
			'EstimateSkew', false, ...
			'EstimateTangentialDistortion', true, ...
			'NumRadialDistortionCoefficients', 2, ...
			'WorldUnits', 'millimeters', ...
			'ImageSize', imageSize);
	end

	imagesUsed = true(size(imagePoints,3),1);

	stats.ReprojectedPoints      = cameraParams.ReprojectedPoints;
	stats.ReprojectionErrors     = cameraParams.ReprojectionErrors;
	stats.MeanReprojectionError  = cameraParams.MeanReprojectionError;
	stats.WorldPoints            = cameraParams.WorldPoints;

else
	disp('--openCV camera estimation--')
	fixed_tilt = use_tilted_model && ~isnan(tilt_angle_y);
	if fixed_tilt
		fprintf('--Scheimpflug tilted sensor model, tilt about y fixed to +/-%.2f deg--\n', abs(tilt_angle_y));
	elseif use_tilted_model
		disp('--Scheimpflug tilted sensor model enabled (CALIB_TILTED_MODEL)--')
	else
		disp('--Standard distortion model--')
	end

	% ============================================================
	% DEPLOYED (OpenCV) VERSION
	% ============================================================
	tilt_candidates = [];
	if fixed_tilt
		% standard calibration as start values, then the tilted model with tauY fixed to
		% both signs of the angle. The images cannot tell the sign: both fit equally well,
		% only the principal point moves (by about f*tan(angle)). Keep the sign that puts
		% the principal point closer to the image centre (where the optical axis of a
		% Scheimpflug adapter meets the sensor).
		if ~isempty(initParams)
			Kmatlab = initParams.IntrinsicMatrix;
			K_start = [ Kmatlab(1,1)  0               Kmatlab(3,1);
				0             Kmatlab(2,2)    Kmatlab(3,2);
				0             0               1 ];
			[Kb, Db, ~, ~] = opencv.opencv_calibrate_basic(imagePoints, worldPoints, imageSize, ...
				K_start, [initParams.RadialDistortion initParams.TangentialDistortion]);
		else
			[Kb, Db, ~, ~] = opencv.opencv_calibrate_basic(imagePoints, worldPoints, imageSize);
		end
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
			[Ks, Ds, rvecs_s, tvecs_s] = opencv.opencv_calibrate_tilted( ...
				imagePoints, worldPoints, imageSize, Kb, D_start, true);
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
	elseif ~isempty(initParams)
		Kmatlab = initParams.IntrinsicMatrix;
		K_init = [ Kmatlab(1,1)  0               Kmatlab(3,1);
			0             Kmatlab(2,2)    Kmatlab(3,2);
			0             0               1 ];
		D_init = [initParams.RadialDistortion initParams.TangentialDistortion];

		if use_tilted_model
			[K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_tilted( ...
				imagePoints, worldPoints, imageSize, K_init, D_init);
		else
			[K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_basic( ...
				imagePoints, worldPoints, imageSize, K_init, D_init);
		end
	else
		if use_tilted_model
			[K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_tilted( ...
				imagePoints, worldPoints, imageSize);
		else
			[K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_basic( ...
				imagePoints, worldPoints, imageSize);
		end
	end

	% ---- Validate the solution before it propagates further
	% An ill-conditioned image set (e.g. boards tilted about a single axis) makes
	% OpenCV return a physically invalid result: the principal point lands outside
	% the image and/or the focal length runs away. The first (no-guess) pass does
	% not flag this, and the refinement pass then feeds it back into OpenCV with
	% CALIB_USE_INTRINSIC_GUESS, where it throws a cryptic
	% "Principal point must be within the image" assertion. Catch it here instead and
	% raise a clear, identifiable error so the caller can show actionable guidance.
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

	% ---- Convert K to MATLAB format
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

	% ---- Compute reprojection stats
	% Projection with OpenCV's full model (K2, D2 incl. tauX, tauY). MATLAB's worldToImage
	% has no tilted sensor and gave far too large errors for the tilted model.
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

		validMask = ~isnan(imagePoints(:,1,v)) & ...
			~isnan(imagePoints(:,2,v));

		if sum(validMask) < 4
			continue
		end

		validIndex = validIndex + 1;
		imagesUsed(v) = true;

		wp = worldPoints(validMask,:);
		wp3 = [wp zeros(size(wp,1),1)];

		proj = project_points_opencv(wp3, rvecs2(validIndex,:), tvecs2(validIndex,:), K_cv, D2);

		ReprojectedPoints(validMask,:,v) = proj;

		err = imagePoints(validMask,:,v) - proj;
		ReprojectionErrors(validMask,:,v) = err;

		allErrors = [allErrors; sqrt(sum(err.^2,2))];

	end

	stats.ReprojectedPoints     = ReprojectedPoints;
	stats.ReprojectionErrors    = ReprojectionErrors;
	stats.MeanReprojectionError = mean(allErrors);
	stats.WorldPoints           = worldPoints;
	stats.tilted_model          = use_tilted_model;
	stats.tilt_candidates       = tilt_candidates; % fixed tilt: both signs (angle, principal point)
	stats.D_full                = D2;   % full distortion vector (4 or 14 elements)
	% K in OpenCV format — needed by opencv_undistort
	stats.K_opencv              = [ K2(1,1)  0         K2(1,3);
		0         K2(2,2)  K2(2,3);
		0         0        1       ];
end
end

function p = project_points_opencv(X, rvec, tvec, K, D)
% OpenCV projectPoints: rotation vector, radial + tangential + rational + thin prism
% distortion and the tilted sensor (tauX, tauY). X [n x 3], p [n x 2].
d = zeros(1, 14);
d(1:numel(D)) = D(:)';
R = rotvec2mat3d(rvec);
Xc = R * X' + tvec(:);
x = (Xc(1,:) ./ Xc(3,:))';
y = (Xc(2,:) ./ Xc(3,:))';
r2 = x .^ 2 + y .^ 2;
kr = (1 + ((d(5) * r2 + d(2)) .* r2 + d(1)) .* r2) ./ (1 + ((d(8) * r2 + d(7)) .* r2 + d(6)) .* r2);
xd = x .* kr + 2 * d(3) * x .* y + d(4) * (r2 + 2 * x .^ 2) + d(9) * r2 + d(10) * r2 .^ 2;
yd = y .* kr + d(3) * (r2 + 2 * y .^ 2) + 2 * d(4) * x .* y + d(11) * r2 + d(12) * r2 .^ 2;
% tilt projection matrix (OpenCV computeTiltProjectionMatrix)
ctx = cos(d(13)); stx = sin(d(13));
cty = cos(d(14)); sty = sin(d(14));
rot_xy = [cty 0 -sty; 0 1 0; sty 0 cty] * [1 0 0; 0 ctx stx; 0 -stx ctx];
T = [rot_xy(3,3) 0 -rot_xy(1,3); 0 rot_xy(3,3) -rot_xy(2,3); 0 0 1] * rot_xy;
P = T * [xd'; yd'; ones(1, numel(xd))];
p = [K(1,1) * (P(1,:) ./ P(3,:))' + K(1,3), K(2,2) * (P(2,:) ./ P(3,:))' + K(2,3)];
end