function [cameraParams, imagesUsed, stats] = ...
    pivlab_estimateCameraParameters(imagePoints, worldPoints, imageSize, varargin)
'show reprojection errors muss noch gemacht werden...!'
% ============================================================
% DESKTOP MATLAB VERSION
% ============================================================
if isdeployed %run this only in non-deployed version
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

    % ============================================================
    % DEPLOYED (OpenCV) VERSION
    % ============================================================

    % ---- Optional initial guess
    if nargin == 4
        initParams = varargin{1};
        Kmatlab = initParams.IntrinsicMatrix;

        K_init = [ Kmatlab(1,1)  0               Kmatlab(3,1);
            0             Kmatlab(2,2)    Kmatlab(3,2);
            0             0               1 ];
        D_init = [initParams.RadialDistortion ...
            initParams.TangentialDistortion];

        [K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_basic( ...
            imagePoints, worldPoints, imageSize, K_init, D_init);
    else
        [K2, D2, rvecs2, tvecs2] = opencv.opencv_calibrate_basic( ...
            imagePoints, worldPoints, imageSize);
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
        'TranslationVectors', tvecs2, ...
        'ImageSize', imageSize);

    % ---- Compute reprojection stats
    numImages = size(imagePoints,3);
    ReprojectedPoints = nan(size(imagePoints));
    ReprojectionErrors = nan(size(imagePoints));
    imagesUsed = false(numImages,1);
    allErrors = [];

    for v = 1:numImages

        validMask = ~isnan(imagePoints(:,1,v)) & ...
            ~isnan(imagePoints(:,2,v));

        if sum(validMask) < 4
            continue
        end

        imagesUsed(v) = true;

        R = rotationVectorToMatrix(rvecs2(v,:));

        wp = worldPoints(validMask,:);
        wp3 = [wp zeros(size(wp,1),1)];

        proj = worldToImage(cameraParams, R, tvecs2(v,:), wp3, ...
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
end