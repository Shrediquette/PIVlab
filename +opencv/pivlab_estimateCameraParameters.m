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
initParams = [];
use_tilted_model = false;
i = 1;
while i <= numel(varargin)
	if isa(varargin{i}, 'cameraParameters')
		initParams = varargin{i};
		i = i + 1;
	elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'use_tilted_model')
		use_tilted_model = logical(varargin{i+1});
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
	if use_tilted_model
		disp('--Scheimpflug tilted sensor model enabled (CALIB_TILTED_MODEL)--')
	else
		disp('--Standard distortion model--')
	end

	% ============================================================
	% DEPLOYED (OpenCV) VERSION
	% ============================================================
	if ~isempty(initParams)
		Kmatlab = initParams.IntrinsicMatrix;
		K_init = [ Kmatlab(1,1)  0               Kmatlab(3,1);
			0             Kmatlab(2,2)    Kmatlab(3,2);
			0             0               1 ];
		% D_init: use full D if available from a prior tilted run
		if isfield(initParams, 'D_full')
			D_init = initParams.D_full;
		else
			D_init = [initParams.RadialDistortion initParams.TangentialDistortion];
		end

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

		R = rotationVectorToMatrix(rvecs2(validIndex,:));

		wp = worldPoints(validMask,:);
		wp3 = [wp zeros(size(wp,1),1)];

		proj = worldToImage(cameraParams, R, tvecs2(validIndex,:), wp3, ...
			'ApplyDistortion', true);

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
	stats.D_full                = D2;   % full distortion vector (4 or 14 elements)
	% K in OpenCV format — needed by opencv_undistort
	stats.K_opencv              = [ K2(1,1)  0         K2(1,3);
		0         K2(2,2)  K2(2,3);
		0         0        1       ];
end