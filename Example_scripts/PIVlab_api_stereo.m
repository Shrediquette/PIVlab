% Stereo-PIV from the command line (pivlab.* API)
% Two cameras look at the same light sheet. pivlab.stereo makes the stereo calibration from one image of
% a ChArUco board in the light sheet per camera, corrects the disparity (the light sheet is not exactly at
% the board), analyses both cameras and combines them to U, V and the out-of-plane component W.
% The result works with pivlab.filter, toMetric, derive, temporal, display and saveSession like a 2D result.
% Type "help pivlab.stereo" for all options.
%
% The example uses the synthetic recording of a free jet in Example_data/stereo_free_jet (see
% Information.txt there). For your own recording, replace the file names below. You need per camera:
% - the particle images (both cameras recorded at the same time, same number of images)
% - a lens calibration ("Save camera parameters" in the camera calibration panel of PIVlab)
% - an image of the ChArUco board in the light sheet

clc; clear; close all
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)

%% Files of the recording
data = fullfile(project_root, 'Example_data', 'stereo_free_jet');
images_cam1 = fullfile(data, 'camera1', 'particle_images', '*.jpg');
images_cam2 = fullfile(data, 'camera2', 'particle_images', '*.jpg');
lens_cam1   = fullfile(data, 'camera1', 'lens_cam1.mat');
lens_cam2   = fullfile(data, 'camera2', 'lens_cam2.mat');
board_cam1  = fullfile(data, 'camera1', 'board_in_light_sheet_cam1.jpg');
board_cam2  = fullfile(data, 'camera2', 'board_in_light_sheet_cam2.jpg');
delta_t     = 0.001;    % time between the two images of a pair in s

% ChArUco board: number of squares, square and marker size in mm (as in the Stereo-PIV panel of PIVlab)
board = struct('PatternDims', [10 18], 'CheckerSize', 12, 'MarkerSize', 9, ...
    'MarkerFamily', "DICT_4X4_1000", 'OriginCheckerColor', "black");

%% 1) Images and lens calibration of both cameras
imgs = cell(1, 2);
imgs{1} = pivlab.readImages(images_cam1, "pairwise");
imgs{1} = pivlab.preprocess(imgs{1}, Camera=lens_cam1);
imgs{2} = pivlab.readImages(images_cam2, "pairwise");
imgs{2} = pivlab.preprocess(imgs{2}, Camera=lens_cam2);

%% 2) Stereo-PIV analysis
% Default: PIVlab default settings for the pre-processing and the PIV analysis of both cameras,
% automatic region of interest (overlap of both views), automatic number of image pairs for the disparity.
res = pivlab.stereo(imgs, {board_cam1, board_cam2}, board);
% more options, e.g. the settings of a PIVlab session (pre-processing, PIV, Stereo-PIV panel):
% s = pivlab.loadSettings('my_stereo_session.mat');
% res = pivlab.stereo(imgs, {board_cam1, board_cam2}, board, Settings=s);
fprintf('Disparity (as in the Stereo-PIV panel of PIVlab):\n');
fprintf('  %s\n', res.stereo.disparity.report{:});

%% 3) Vector validation: both cameras are validated, then U, V, W are made again
% Velocity limits act on U, V of the 3D result, NotchLimits on the 3D magnitude.
res = pivlab.filter(res);
% res = pivlab.filter(res, VelocityLimits=[-10 10 -5 5]);

%% 4) Calibration: the scale comes from the stereo calibration, only the time step is needed
res = pivlab.toMetric(res, DeltaT=delta_t);
% res.x, res.y in m; res.u, res.v, res.w in m/s (w positive away from camera 1)

%% 5) Derived quantities, statistics, figures
[res, w] = pivlab.derive(res, "w");                 % out-of-plane component
[res, magnitude] = pivlab.derive(res, "magnitude"); % 3D magnitude sqrt(u^2 + v^2 + w^2)
m = pivlab.temporal(res, "mean");                   % mean of U, V and W
pivlab.display(m, Overlay="w");
pivlab.display(res, Frame=1, Overlay="residual");   % how well both cameras fit one 3D velocity (px)

%% 6) Save a session that opens in the PIVlab GUI (both cameras, calibration, disparity)
pivlab.saveSession(res, fullfile(tempdir, 'PIVlab_api_stereo_session.mat'));
% A stereo session made in the GUI can be loaded the same way:
% r = pivlab.loadSession('my_stereo_session.mat');
