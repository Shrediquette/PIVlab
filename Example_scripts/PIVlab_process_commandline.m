% Example script: process PIV images from the command line
% This script shows the full workflow:
% 1) load image pairs
% 2) preprocess the images
% 3) run the PIV analysis
% 4) postprocess the vector field
% The script is written as a teaching example and therefore keeps the
% workflow explicit instead of hiding steps in helper functions.

clc
clear
close all

%% Tell MATLAB where the PIVlab package folders are
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(project_root)

%% Select the folder that contains the images to analyze
% The example data folder is used here. Replace it with your own folder if needed.
image_folder = fullfile(project_root, 'Example_data');
file_pattern = '*.jpg'; % for example '*.bmp', '*.tif', '*.png', '*.jpg'

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

%% Define preprocessing settings
% These settings are applied to every image before the PIV analysis.
roi_inpt = [];            % [] means: use the full image. Otherwise: [x, y, width, height]
clahe = 1;                % contrast enhancement
clahesize = 64;           % size of the local contrast tiles
highp = 0;                % high-pass filter
highpsize = 15;           % size of the high-pass filter
intenscap = 0;            % intensity capping
wienerwurst = 0;          % Wiener filter
wienerwurstsize = 3;      % Wiener filter size
minintens = 0.0;          % lower intensity limit
maxintens = 1.0;          % upper intensity limit

%% Define PIV analysis settings
% Required for piv.piv_FFTmulti are:
% image1, image2, interrogationarea
%
% The remaining arguments are shown explicitly here so it is clear how they
% can be controlled from a script.
interrogationarea = 64;   % first pass interrogation window size
step = 32;                % distance between neighboring vectors
subpixfinder = 1;         % 1 = 3-point Gauss, 2 = 2D Gauss
mask_inpt = [];           % [] means: no mask. Otherwise: logical matrix, same size as images (true = masked out)
passes = 2;               % number of passes
int2 = 32;                % interrogation area in pass 2
int3 = 16;                % interrogation area in pass 3
int4 = 16;                % interrogation area in pass 4
imdeform = '*linear';     % '*linear' or '*spline'
repeat = 0;               % repeated correlation
mask_auto = 0;            % disable autocorrelation in first pass
do_linear_correlation = 0;% 0 = circular, 1 = linear
repeat_last_pass = 0;     % repeat the last pass
delta_diff_min = 0.025;   % stop repeated last pass below this improvement
limit_peak_search_area = 1;% 1 = limit peak search to central region (recommended), 0 = search full correlation map

%% Define mask (optional)
% To mask a region, create a logical matrix the same size as the images where true = masked out.
% Example: mask a rectangular region covering the nozzle on the right side of the image.
img_size = size(imread(fullfile(image_folder, image_names{1})));
mask_inpt = false(img_size(1), img_size(2));
mask_inpt(454:884, 1250:end) = true;

%% Define postprocessing settings
% These settings are applied to the raw vector field after the PIV analysis.
calu = 1;                           % calibration factor for u
calv = 1;                           % calibration factor for v
valid_vel = [-50; 50; -50; 50];     % [u_min; u_max; v_min; v_max]
do_stdev_check = 1;                 % global standard deviation check
stdthresh = 7;                      % threshold for the standard deviation check
do_local_median = 1;                % local median check
neigh_thresh = 3;                   % threshold for the local median check
paint_nan = 1;                      % fill filtered vectors by interpolation

%% Prepare result variables
% All results are stored in 3D matrices:
% first dimension = vertical position
% second dimension = horizontal position
% third dimension = image pair number / time step
x = [];
y = [];
u = [];
v = [];
typevector = [];
correlation_map = [];
u_filt = [];
v_filt = [];
typevector_filt = [];

%% Main loop over all image pairs
for pair_idx = 1:num_pairs
    % Images 1+2 are the first pair, 3+4 the second pair, and so on.
    image_name_1 = image_names{2 * pair_idx - 1};
    image_name_2 = image_names{2 * pair_idx};

    disp(['Processing pair ' num2str(pair_idx) ' of ' num2str(num_pairs) ...
        ': ' image_name_1 ' and ' image_name_2])

    %% Load the raw images
    image1_raw = imread(fullfile(image_folder, image_name_1));
    image2_raw = imread(fullfile(image_folder, image_name_2));

    %% Preprocess the raw images
    image1_preprocessed = preproc.PIVlab_preproc( ...
        in=image1_raw, ...
        roirect=roi_inpt, ...
        clahe=clahe, ...
        clahesize=clahesize, ...
        highp=highp, ...
        highpsize=highpsize, ...
        intenscap=intenscap, ...
        wienerwurst=wienerwurst, ...
        wienerwurstsize=wienerwurstsize, ...
        minintens=minintens, ...
        maxintens=maxintens);

    image2_preprocessed = preproc.PIVlab_preproc( ...
        in=image2_raw, ...
        roirect=roi_inpt, ...
        clahe=clahe, ...
        clahesize=clahesize, ...
        highp=highp, ...
        highpsize=highpsize, ...
        intenscap=intenscap, ...
        wienerwurst=wienerwurst, ...
        wienerwurstsize=wienerwurstsize, ...
        minintens=minintens, ...
        maxintens=maxintens);

    %% Run the actual PIV analysis
    [x(:,:,pair_idx), y(:,:,pair_idx), u(:,:,pair_idx), v(:,:,pair_idx), ...
        typevector(:,:,pair_idx), correlation_map(:,:,pair_idx)] = piv.piv_FFTmulti( ...
        image1=image1_preprocessed, ...
        image2=image2_preprocessed, ...
        interrogationarea=interrogationarea, ...
        step=step, ...
        subpixfinder=subpixfinder, ...
        mask_inpt=mask_inpt, ...
        roi_inpt=roi_inpt, ...
        passes=passes, ...
        int2=int2, ...
        int3=int3, ...
        int4=int4, ...
        imdeform=imdeform, ...
        repeat=repeat, ...
        mask_auto=mask_auto, ...
        do_linear_correlation=do_linear_correlation, ...
        repeat_last_pass=repeat_last_pass, ...
        delta_diff_min=delta_diff_min, ...
        limit_peak_search_area=limit_peak_search_area);

    %% Postprocess the vector field
    [u_filt(:,:,pair_idx), v_filt(:,:,pair_idx)] = postproc.PIVlab_postproc( ...
        u=u(:,:,pair_idx), ...
        v=v(:,:,pair_idx), ...
        calu=calu, ...
        calv=calv, ...
        valid_vel=valid_vel, ...
        do_stdev_check=do_stdev_check, ...
        stdthresh=stdthresh, ...
        do_local_median=do_local_median, ...
        neigh_thresh=neigh_thresh);

    % Keep track of which vectors were filtered.
    typevector_filt_slice = typevector(:,:,pair_idx);
    typevector_filt_slice(isnan(u_filt(:,:,pair_idx))) = 2;
    typevector_filt_slice(isnan(v_filt(:,:,pair_idx))) = 2;
    typevector_filt_slice(typevector(:,:,pair_idx) == 0) = 0;
    typevector_filt(:,:,pair_idx) = typevector_filt_slice;

    % Optionally fill filtered vectors by interpolation.
    if paint_nan
        u_filt(:,:,pair_idx) = misc.inpaint_nans(u_filt(:,:,pair_idx), 4);
        v_filt(:,:,pair_idx) = misc.inpaint_nans(v_filt(:,:,pair_idx), 4);
    end
end

% Ensure masked regions stay NaN (inpaint_nans may have filled them).
u_filt(typevector == 0) = NaN;
v_filt(typevector == 0) = NaN;

disp('Processing finished.')
disp('Now run Example_scripts/PIVlab_visualize_commandline.m to create figures from the results.')
