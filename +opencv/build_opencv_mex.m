% Build script for PIVlab OpenCV MEX files.
% Run from your interactive MATLAB session (not via MCP server).

clc
mex -setup C++

OPENCV_INCLUDE = 'C:\Users\trash\Documents\MATLAB\openCV\opencv\build\include';
OPENCV_LIB     = 'C:\Users\trash\Documents\MATLAB\openCV\opencv\build\x64\vc16\lib\opencv_world4130.lib';

src_dir = fileparts(mfilename('fullpath'));

disp('Building opencv_calibrate_basic ...')
mex('-v', '-outdir', src_dir, ['-I' OPENCV_INCLUDE], OPENCV_LIB, fullfile(src_dir, 'opencv_calibrate_basic.cpp'))

disp('Building opencv_calibrate_tilted ...')
mex('-v', '-outdir', src_dir, ['-I' OPENCV_INCLUDE], OPENCV_LIB, fullfile(src_dir, 'opencv_calibrate_tilted.cpp'))

disp('Building opencv_undistort ...')
mex('-v', '-outdir', src_dir, ['-I' OPENCV_INCLUDE], OPENCV_LIB, fullfile(src_dir, 'opencv_undistort.cpp'))

disp('All MEX files built successfully.')
