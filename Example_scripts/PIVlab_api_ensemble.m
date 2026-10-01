% PIVlab ensemble correlation from the command line (pivlab.* API)
% Ensemble correlation averages the correlation matrices of all image pairs before the
% displacement is determined. This gives one reliable vector field for flows with low
% seeding density (e.g. micro-PIV) or noisy images, but no time-resolved information.

clc; clear; close all
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)

%% images, pre-processing
imgs = pivlab.readImages(fullfile(project_root,'Example_data','Jet_*.jpg'), "pairwise");
imgs = pivlab.preprocess(imgs);

%% ensemble analysis: one vector field for all pairs
res = pivlab.analyze(imgs, Algorithm="ensemble", InterrogationArea=64, Passes=2, PassSizes=[32 32 32]);

%% validation, calibration, derived quantities
res = pivlab.filter(res);
res = pivlab.toMetric(res, DeltaT=0.001, PxPerMeter=1234);
[res, magnitude] = pivlab.derive(res, "magnitude");

%% figures
pivlab.display(res, Overlay="magnitude", VectorSkip=2);
pivlab.display(res, Overlay="correlation", Vectors=false, Colormap="gray");

%% a profile through the field: u along the horizontal centre line
row = round(size(res.x,1)/2);
figure;
plot(res.x(row,:), res.u(row,:), '-o');
xlabel('x in m'); ylabel('u in m/s'); grid on
title('Ensemble result: u along the centre line')
