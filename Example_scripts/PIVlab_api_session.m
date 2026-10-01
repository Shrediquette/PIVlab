% Working with PIVlab sessions and settings from the command line (pivlab.* API)
% 1) Re-use the settings of a GUI session (or of a settings file) for a batch analysis
% 2) Load the results of a session and make publication figures
% 3) Save the batch result as a session and open it in the GUI

clc; clear; close all
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)
session_file = fullfile(tempdir, 'PIVlab_api_example_session.mat');

%% make a session (in practice: a session saved with "File -> Save session" in PIVlab)
imgs = pivlab.preprocess(pivlab.readImages(fullfile(project_root,'Example_data','Jet_*.jpg'), "pairwise"), Roi=[100 100 900 700]);
res  = pivlab.filter(pivlab.analyze(imgs, Passes=3, PassSizes=[32 24 24], Pairs=1:3));
res  = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234);
pivlab.saveSession(res, session_file);

%% 1) settings of the session -> analyse all images with exactly these settings
% pivlab.loadSettings detects automatically whether the file is a session or a settings file.
s = pivlab.loadSettings(session_file);
disp(s.analysis)                       % the analysis settings of the session
imgs = pivlab.readImages(fullfile(project_root,'Example_data','Jet_*.jpg'), "pairwise");
imgs = pivlab.preprocess(imgs, Settings=s);   % incl. region of interest of the session
res  = pivlab.analyze(imgs, Settings=s);
res  = pivlab.filter(res, Settings=s);
res  = pivlab.toMetric(res, Settings=s);      % calibration of the session

%% 2) results of a session -> statistics and figures
r = pivlab.loadSession(session_file);
m = pivlab.temporal(r, "mean");
pivlab.display(m, Overlay="magnitude", Colormap="parula", ReferenceVector="top right", ReferenceLength=1);

%% 3) save the batch result as a session; open it in PIVlab with File -> Load session
pivlab.saveSession(res, fullfile(tempdir, 'PIVlab_api_batch_session.mat'));
