% Example script: ensemble PIV from the command line using piv_FFTensemble
% Use this approach when your seeding density is low (e.g. microPIV) and
% you want to accumulate correlations across many image pairs before
% finding the displacement peak.
%
% Compared to PIVlab_process_commandline.m (which uses piv_FFTmulti):
%   - No per-pair loop: all file paths are passed to piv_FFTensemble at once
%   - Preprocessing is handled inside piv_FFTensemble (no separate preproc call)
%   - The output is a single 2-D velocity field, not one slice per pair

clc
clear
close all

%% Tell MATLAB where the PIVlab package folders are
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)

%% Select the folder that contains the images to analyze
% The example data folder is used here. Replace it with your own folder if needed.
image_folder = fullfile(project_root, 'Example_data');
file_pattern = 'Jet_*.jpg'; % for example '*.bmp', '*.tif', '*.png', '*.jpg'

disp(['Looking for ' file_pattern ' files in: ' image_folder])

image_files = dir(fullfile(image_folder, file_pattern));
image_names = {image_files.name}';
image_names = sortrows(image_names);

if isempty(image_names)
    error('No images found. Please check image_folder and file_pattern.')
end

if mod(numel(image_names), 2) ~= 0
    error('The image folder must contain an even number of images because PIVlab analyzes image pairs.')
end

num_pairs = numel(image_names) / 2;
disp(['Found ' num2str(numel(image_names)) ' images, i.e. ' num2str(num_pairs) ' image pairs.'])

% piv_FFTensemble expects a column cell array of full file paths, interleaved
% as: {A1; B1; A2; B2; ...}. Sorting the Jet_*.jpg files alphabetically gives
% exactly this order because the A/B suffix comes after the pair number.
filepath = fullfile(image_folder, image_names);

%% Define PIV analysis settings
% piv_FFTensemble handles preprocessing internally via the same parameters
% that piv_FFTmulti exposes through the preproc package.
interrogationarea = 64;   % first pass interrogation window size
step              = 32;   % distance between neighboring vectors
subpixfinder      = 1;    % 1 = 3-point Gauss, 2 = 2D Gauss
passes            = 2;    % number of passes
int2              = 32;   % interrogation area in pass 2
imdeform          = '*linear'; % '*linear' or '*spline'
clahe             = 1;    % contrast enhancement
clahesize         = 64;   % size of the local contrast tiles
highp             = 0;    % high-pass filter
intenscap         = 0;    % intensity capping
wienerwurst       = 0;    % Wiener filter
roi_inpt          = [];   % [] means: use the full image. Otherwise: [x, y, width, height]

%% Run the ensemble PIV analysis (single call — no loop needed)
disp('Running ensemble PIV analysis...')
[x, y, u, v, typevector, correlation_map] = piv.piv_FFTensemble( ...
    filepath=filepath, ...
    interrogationarea=interrogationarea, ...
    step=step, ...
    subpixfinder=subpixfinder, ...
    passes=passes, ...
    int2=int2, ...
    imdeform=imdeform, ...
    clahe=clahe, ...
    clahesize=clahesize, ...
    highp=highp, ...
    intenscap=intenscap, ...
    wienerwurst=wienerwurst, ...
    roi_inpt=roi_inpt);

disp('Ensemble correlation finished.')

%% Define postprocessing settings
calu       = 1;                       % calibration factor for u
calv       = 1;                       % calibration factor for v
valid_vel  = [-50; 50; -50; 50];      % [u_min; u_max; v_min; v_max]
do_stdev_check = 1;                   % global standard deviation check
stdthresh  = 7;                       % threshold for the standard deviation check
do_local_median = 1;                  % local median check
neigh_thresh = 3;                     % threshold for the local median check
paint_nan  = 1;                       % fill filtered vectors by interpolation

%% Postprocess the ensemble velocity field
[u_filt, v_filt] = postproc.PIVlab_postproc( ...
    u=u, ...
    v=v, ...
    calu=calu, ...
    calv=calv, ...
    valid_vel=valid_vel, ...
    do_stdev_check=do_stdev_check, ...
    stdthresh=stdthresh, ...
    do_local_median=do_local_median, ...
    neigh_thresh=neigh_thresh);

% Keep track of which vectors were filtered.
typevector_filt = typevector;
typevector_filt(isnan(u_filt) | isnan(v_filt)) = 2;
typevector_filt(typevector == 0) = 0;

% Optionally fill filtered vectors by interpolation.
if paint_nan
    u_filt(typevector == 0) = NaN;
    v_filt(typevector == 0) = NaN;
    u_filt = misc.inpaint_nans(u_filt, 4);
    v_filt = misc.inpaint_nans(v_filt, 4);
end

% Ensure masked regions stay NaN (inpaint_nans may have filled them).
u_filt(typevector == 0) = NaN;
v_filt(typevector == 0) = NaN;

disp('Processing finished.')
disp('Now run Example_scripts/PIVlab_visualize_ensemble_commandline.m to create figures from the results.')
