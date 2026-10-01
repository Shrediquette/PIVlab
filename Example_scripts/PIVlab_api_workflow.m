% PIVlab command-line workflow (pivlab.* API)
% This script runs a complete PIV analysis without the GUI, using the same functions as the
% PIVlab GUI. Every step works with the PIVlab defaults; optional settings are shown as
% name=value arguments. Type "help pivlab" for an overview and "help pivlab.<function>"
% for all options of a step.

clc; clear; close all

%% Tell MATLAB where PIVlab is
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)

%% 1) Select the images and the sequencing
% "pairwise":     A+B, C+D, E+F, ...  (double-frame cameras)
% "timeresolved": A+B, B+C, C+D, ...  (high-speed cameras)
imgs = pivlab.readImages(fullfile(project_root,'Example_data','Jet_*.jpg'), "pairwise");
fprintf('%d image pairs found.\n', imgs.pairs);

%% 2) Pre-processing
% Default: CLAHE (contrast enhancement) and automatic intensity stretching.
% The filters are applied to every image pair during the analysis, so nothing is stored here.
imgs = pivlab.preprocess(imgs);
% more options, e.g.:
% imgs = pivlab.preprocess(imgs, Highpass=true, Background="min", Roi=[50 50 1200 900]);
figure; imshow(pivlab.getImage(imgs, 1)); title('Pre-processed image A of pair 1')

%% 3) PIV analysis
% Default: multipass FFT window deformation, 64 px windows (50 % overlap), second pass 32 px.
res = pivlab.analyze(imgs);
% more options, e.g.:
% res = pivlab.analyze(imgs, InterrogationArea=64, Passes=3, PassSizes=[32 16 16], Robustness="high", Parallel=true);

%% 4) Vector validation: remove outliers and interpolate the gaps
res = pivlab.filter(res);
% more options, e.g.:
% res = pivlab.filter(res, StdevThreshold=5, LocalMedianThreshold=2, VelocityLimits=[-10 20 -10 10]);

%% 5) Calibration: pixels -> metres, pixels per image pair -> m/s
delta_t = 0.001;        % time between the two images of a pair in s
px_per_meter = 1234;    % image scale from a calibration image
res = pivlab.toMetric(res, DeltaT=delta_t, PxPerMeter=px_per_meter);
% res.x, res.y are now in m; res.u, res.v in m/s

%% 6) Temporal statistics
% Plain MATLAB works on res.u / res.v (third dimension = image pair):
mean_u = mean(res.u, 3, 'omitnan');
std_u  = std(res.u, 0, 3, 'omitnan');
% pivlab.temporal gives a result that can be displayed, derived and saved like PIVlab does it:
m = pivlab.temporal(res, "mean");
s = pivlab.temporal(res, "std");

%% 7) Derived quantities (for every image pair, or for the temporal statistics)
[res, vorticity] = pivlab.derive(res, "vorticity");   % 1/s, H x W x pairs
[res, magnitude] = pivlab.derive(res, "magnitude");   % m/s
[m, mean_magnitude] = pivlab.derive(m, "magnitude");

%% 8) Figures like in the PIVlab GUI
pivlab.display(res, Frame=1, Overlay="vorticity");
pivlab.display(m, Overlay="magnitude", Colormap="jet", VectorColor="white", ReferenceVector="top right", ReferenceLength=0.5);
pivlab.display(s, Overlay="magnitude", Vectors=false);
% save a figure:
% exportgraphics(gca, 'mean_velocity.png', Resolution=300)

%% 9) Save a PIVlab session that can be opened (and changed) in the PIVlab GUI
pivlab.saveSession(res, fullfile(tempdir, 'PIVlab_api_session.mat'));
% PIVlab_GUI  -> File -> Load session
