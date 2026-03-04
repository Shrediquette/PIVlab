%% compile mex file
clear all
clc
%{
%auswählen Microsoft visual c++
mex -setup C
mex -setup C++
mex -I"C:\Users\thiel\Documents\MATLAB\opencv_test\opencv\build\include" ...
    -L"C:\Users\thiel\Documents\MATLAB\opencv_test\opencv\build\x64\vc16\lib" ...
    -lopencv_world4130 ...
    opencv_calibrate_basic.cpp
%}

%% Test

imds = imageDatastore(fullfile(toolboxdir('vision'),'visiondata',...
    'calibration','mono'));
imageFileNames = imds.Files;

[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);

squareSizeInMM = 29;
worldPoints = patternWorldPoints("checkerboard",boardSize,squareSizeInMM);


I = preview(imds);
imageSize = [size(I, 1),size(I, 2)];


%% Baseline using Matlab
tic
params = estimateCameraParameters( ...
    imagePoints, ...
    worldPoints, ...
    'ImageSize', imageSize, ...
    'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 2);
toc
%% Same using openCV
tic
[params2, imagesUsed, stats] = opencv.pivlab_estimateCameraParameters(imagePoints, worldPoints, imageSize);
params2.PrincipalPoint
toc
%second pass
tic
[params2, imagesUsed, stats] = opencv.pivlab_estimateCameraParameters(imagePoints, worldPoints, imageSize, params2);
params2.PrincipalPoint
toc
I1 = undistortImage(I, params);
I2 = undistortImage(I, params2);
figure;imshow(I)
figure;imshow(I1)
figure;imshow(I2)
max(abs(double(I1(:)) - double(I2(:))))