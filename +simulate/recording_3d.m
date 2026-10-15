function result = recording_3d(setup, folder, opts)
% Synthetic stereo-PIV (or single camera 3D) recording with everything that is needed to test the
% whole PIVlab workflow: lens calibration, stereo calibration, disparity correction, PIV, 3C reconstruction.
%   result = simulate.recording_3d(setup, folder)
%   result = simulate.recording_3d(setup, folder, Progress=@(text) disp(text))
% setup: see simulate.setup_3d (cameras, lens, board, light sheet, flow, particles, output)
%
% Written to folder (k = camera number):
%   camera<k>/particle_images/cam<k>_0001_A.tif, cam<k>_0001_B.tif, ...   image pairs (same flow, new particles)
%   camera<k>/board_in_light_sheet_cam<k>.tif    the board where the light sheet is (stereo calibration)
%   camera<k>/calibration_images/calib_cam<k>_01.tif, ...   the board in random positions (lens calibration)
%   camera<k>/true_lens_cam<k>.mat     the true lens: file of "Load camera parameters" (for comparison)
%   ground_truth.mat                   displacement field and geometry (see simulate.truth_at_board)
%   generator_setup.mat                the setup that made the recording
%   README.txt                         contents and how to use them in PIVlab
% The light sheet may be offset and tilted against the board (setup.sheet): the disparity correction
% of the stereo-PIV panel has to find it.
arguments
    setup struct
    folder {mustBeTextScalar}
    opts.Progress = @(text) []      % function handle, called with a status text
    opts.Seed (1,1) double = 1      % random number seed (particles, board poses, noise)
end
folder = char(folder);
progress = opts.Progress;
g = simulate.geometry_3d(setup);
if ~g.ok
    error('simulate:recording_3d:geometry', '%s', g.message);
end
n_cams = numel(g.cams);
sz = setup.sensor.ImageSize;
previous_rng = rng(opts.Seed, 'twister');
restore_rng = onCleanup(@() rng(previous_rng));
if ~isfolder(folder)
    mkdir(folder);
end

%% board texture, shared by all board images (about two texels per image pixel)
board = setup.board;
ppc = 0;
for k = 1:n_cams
    ppc = max(ppc, checker_pixels(g.cams{k}, board, rigidtform3d));
end
progress('Board texture...');
tex = simulate.board_texture(board, min(160, max(16, ceil(2 * ppc))), Decorated=true);

photos = background_photos(setup);
result.folder = folder;
result.particle_images = cell(1, n_cams);
result.board_images = cell(1, n_cams);
result.calibration_images = cell(1, n_cams);
result.lens_files = cell(1, n_cams);
for k = 1:n_cams
    camdir = fullfile(folder, sprintf('camera%d', k));
    make_folder(fullfile(camdir, 'particle_images'));
    make_folder(fullfile(camdir, 'calibration_images'));

    %% board in the light sheet (world = board coordinates)
    progress(sprintf('Camera %d: board in the light sheet...', k));
    I = simulate.charuco_image(g.cams{k}, Texture=tex, Blur=0.8, Noise=0.0005);
    result.board_images{k} = fullfile(camdir, sprintf('board_in_light_sheet_cam%d.tif', k));
    imwrite(I, result.board_images{k});

    %% board in random positions for the lens calibration
    poses = calibration_poses(g.cams{k}, board, setup.output.CalibrationImages);
    files = cell(numel(poses), 1);
    for n = 1:numel(poses)
        progress(sprintf('Camera %d: calibration image %d of %d...', k, n, numel(poses)));
        I = simulate.charuco_image(g.cams{k}, Texture=tex, BoardPose=poses{n}, Blur=0.8, Noise=0.0005, ...
            Background=calibration_background(sz, photos));
        files{n} = fullfile(camdir, 'calibration_images', sprintf('calib_cam%d_%02d.tif', k, n));
        imwrite(I, files{n});
    end
    result.calibration_images{k} = files;

    %% the true lens, as a file of "Load camera parameters" (Camera calibration panel)
    intr = g.cams{k}.intrinsics;
    cameraParams = cameraParameters(K=intr.K, RadialDistortion=intr.RadialDistortion, ...
        TangentialDistortion=intr.TangentialDistortion, ImageSize=sz);
    cam_selected_target_images = files;
    cam_use_tilted_model = false;
    cam_tilted_D = [];
    cam_K_opencv = [];
    result.lens_files{k} = fullfile(camdir, sprintf('true_lens_cam%d.mat', k));
    save(result.lens_files{k}, 'cameraParams', 'cam_selected_target_images', 'cam_use_tilted_model', 'cam_tilted_D', 'cam_K_opencv');
end

%% flow field on a grid in sheet coordinates, around all views
box = g.region;
extent = max(box(2) - box(1), box(4) - box(3));
spacing = extent / 300;
if any(strcmp(setup.flow.Type, {'vortex_jet', 'rankine'}))
    spacing = min(spacing, setup.flow.Radius / 8);
end
pad = 0.1 * extent;
[X, Y] = meshgrid(box(1) - pad:spacing:box(2) + pad + spacing, box(3) - pad:spacing:box(4) + pad + spacing);
[U, V, W] = flow_3d(setup.flow, X, Y, g);

%% particle images
n_particles = round(setup.particles.Density * prod(sz) * (box(2) - box(1)) * (box(4) - box(3)) / mean(area(g.views)));
for k = 1:n_cams
    result.particle_images{k} = strings(0, 1);
end
for n = 1:setup.output.Pairs
    progress(sprintf('Particle images: pair %d of %d...', n, setup.output.Pairs));
    out = simulate.particle_images(Cameras=g.cams, Region=box, X=X, Y=Y, U=U, V=V, W=W, Particles=n_particles, ...
        SheetThickness=setup.sheet.Thickness, SheetPose=g.sheet_pose, PeakIntensity=200, Diameter=setup.particles.Diameter, ...
        DiameterVariation=setup.particles.DiameterVariation, Noise=setup.particles.Noise, Seed=opts.Seed * 100000 + n);
    for k = 1:n_cams
        base = fullfile(folder, sprintf('camera%d', k), 'particle_images', sprintf('cam%d_%04d', k, n));
        imwrite(out.A{k}, [base '_A.tif']);
        imwrite(out.B{k}, [base '_B.tif']);
        result.particle_images{k}(end + 1:end + 2, 1) = [string([base '_A.tif']); string([base '_B.tif'])];
    end
end

%% ground truth
progress('Ground truth...');
truth = ground_truth(setup, g, X, Y, U, V, W);
result.truth_file = fullfile(folder, 'ground_truth.mat');
save(result.truth_file, 'truth');
save(fullfile(folder, 'generator_setup.mat'), 'setup');
write_readme(fullfile(folder, 'README.txt'), setup, g, truth);
result.truth = truth;
progress('...done');
end

function make_folder(p)
if ~isfolder(p)
    mkdir(p);
end
end

function ppc = checker_pixels(cam, board, pose)
% largest size of a checker in the image [px] of the board in this pose
dims = board.PatternDims;
outline = [-1 -1; dims(2) - 1, -1; dims(2) - 1, dims(1) - 1; -1, dims(1) - 1] * board.CheckerSize;
px = simulate.project(cam, transformPointsForward(pose, [outline, zeros(4, 1)]));
ppc = max(vecnorm(diff(px([1:4 1], :)), 2, 2) ./ dims([2 1 2 1])');
end

function photos = background_photos(setup)
% grayscale photos (downscaled) for the background of the calibration images, e.g. of the
% experimenter who holds the board: a mat file with the cell array "backgrounds" (as
% images/calibration_backgrounds.mat) or a folder with photos; none: a synthetic background
photos = {};
folder = '';
if isfield(setup.output, 'Backgrounds')
    folder = char(setup.output.Backgrounds);
end
if isfile(folder)
    loaded = load(folder, 'backgrounds');
    photos = cellfun(@im2double, loaded.backgrounds, 'UniformOutput', false);
    return
end
if isempty(folder) || ~isfolder(folder)
    return
end
files = dir(folder);
files = files(~[files.isdir]);
[~, ~, ext] = cellfun(@fileparts, {files.name}, 'UniformOutput', false);
files = files(ismember(lower(ext), {'.jpg', '.jpeg', '.png', '.tif', '.tiff', '.bmp'}));
for k = 1:numel(files)
    try
        I = im2double(imread(fullfile(files(k).folder, files(k).name)));
    catch
        continue % not an image
    end
    if size(I, 3) == 3
        I = rgb2gray(I);
    elseif size(I, 3) > 1
        I = I(:, :, 1);
    end
    photos{end + 1} = imresize(I, 400 / max(size(I)), 'bilinear'); %#ok<AGROW> (the background is blurred heavily anyway)
end
end

function bg = calibration_background(sz, photos)
% heavily blurred background of a calibration image [counts]: a random part of a random photo
% (zoomed, mirrored, brightness varied), or a synthetic dim scene with a person-like shape
low = max(8, round(sz / 8)); % made at 1/8 resolution, then enlarged
if isempty(photos)
    [x, y] = meshgrid(linspace(0, 1, low(2)), linspace(0, 1, low(1)));
    scene = imresize(rand(4, 4), low, 'bicubic') * 0.5;
    px = 0.2 + 0.6 * rand; % a person: head and body (to the bottom of the image)
    head = exp(-((x - px) .^ 2 / 0.01 + (y - 0.25) .^ 2 / 0.012));
    body = exp(-(x - px) .^ 2 / 0.04) .* (y > 0.4);
    scene = scene + 0.8 * head + 0.6 * body;
else
    P = photos{randi(numel(photos))};
    if rand < 0.5
        P = fliplr(P);
    end
    aspect = sz(2) / sz(1);
    zoom = 1 + 0.8 * rand;
    ch = min(size(P, 1), size(P, 2) / aspect) / zoom;
    cw = ch * aspect;
    y0 = rand * (size(P, 1) - ch);
    x0 = rand * (size(P, 2) - cw);
    [xq, yq] = meshgrid(x0 + linspace(1, cw, low(2)), y0 + linspace(1, ch, low(1)));
    scene = interp2(P, xq, yq, 'linear', 0.5);
end
scene = imgaussfilt(scene, max(low) / 40); % heavy blur: about 5 % of the image width
scene = mat2gray(scene);
dark = 5 + 15 * rand;
bright = dark + 50 + 90 * rand;
bg = imresize(dark + (bright - dark) * scene, sz, 'bicubic');
end

function poses = calibration_poses(cam, board, n)
% n random board poses in front of the camera: tilted by 10..40 deg, rotated by up to 20 deg,
% about 60..95 % of the image width, centre shifted by up to 15 % of the view; at least half of the
% inner corners in the image
dims = board.PatternDims;
checker = board.CheckerSize;
centre = [(dims(2) - 2) * checker / 2, (dims(1) - 2) * checker / 2, 0];
board_width = dims(2) * checker;
wp = patternWorldPoints("charuco-board", dims, checker);
wp = [wp, zeros(size(wp, 1), 1)];
Rc = cam.pose.R; % world -> camera
C = (-Rc' * cam.pose.Translation(:))';
f = cam.intrinsics.FocalLength(1);
w = cam.imageSize(2);
h = cam.imageSize(1);
poses = cell(n, 1);
for k = 1:n
    best = [];
    best_visible = -1;
    for attempt = 1:60
        d = board_width / ((0.6 + 0.35 * rand) * w / f); % distance of the board centre
        fov = [w h] / f * d;
        lateral = (rand(1, 2) - 0.5) * 0.3 .* fov;
        P = C + d * Rc(3, :) + lateral(1) * Rc(1, :) + lateral(2) * Rc(2, :);
        tilt = (10 + 30 * rand(1, 2)) .* sign(rand(1, 2) - 0.5);
        if mod(k, 4) == 1 % some views with a small tilt
            tilt = tilt / 3;
        end
        Rb = Rc' * rot_z(40 * (rand - 0.5)) * rot_y(tilt(2)) * rot_x(tilt(1)); % board -> world: board faces the camera
        pose = rigidtform3d(Rb, P - (Rb * centre(:))');
        px = simulate.project(cam, transformPointsForward(pose, wp));
        Pc = transformPointsForward(cam.pose, transformPointsForward(pose, wp));
        visible = sum(Pc(:, 3) > 0 & px(:, 1) > 3 & px(:, 1) < w - 2 & px(:, 2) > 3 & px(:, 2) < h - 2);
        if visible > best_visible
            best = pose;
            best_visible = visible;
        end
        if visible >= 0.5 * size(wp, 1)
            break
        end
    end
    poses{k} = best;
end
end

function [U, V, W] = flow_3d(flow, X, Y, g)
% displacement [mm per image pair] on the grid X, Y (sheet coordinates), centred in the overlap of the views
[cx, cy] = centroid(g.overlap);
if isnan(cx)
    cx = mean(g.region(1:2));
    cy = mean(g.region(3:4));
end
[ox, oy] = boundary(g.overlap);
half = max(max(ox) - min(ox), max(oy) - min(oy)) / 2;
if isempty(half) || ~(half > 0)
    half = max(g.region(2) - g.region(1), g.region(4) - g.region(3)) / 2;
end
L = 2 * half;
switch flow.Type
    case 'vortex_jet'
        fl = struct('type', 'vortex_jet', 'v0', flow.InPlane, 'R0', flow.Radius, 'c1', [cx cy], 'w_max', flow.OutOfPlane);
        [U, V, W] = simulate.flow_field(fl, X, Y);
        return
    case 'rankine'
        fl = struct('type', 'rankine', 'v0', flow.InPlane, 'R0', flow.Radius, 'c1', [cx cy], 'c2', [cx cy], 'double', false);
        [U, V] = simulate.flow_field(fl, X, Y);
    case 'uniform'
        U = zeros(size(X)) + flow.InPlane;
        V = zeros(size(X));
    case 'rotation' % max displacement at the edge of the overlap
        fl = struct('type', 'rotation', 'rotation', flow.InPlane, 'imageSize', [L L]);
        [U, V] = simulate.flow_field(fl, X - cx + (L + 1) / 2, Y - cy + (L + 1) / 2);
    case 'membrane' % over the overlap, scaled to the max displacement
        fl = struct('type', 'membrane', 'imageSize', [L L]);
        [U, V] = simulate.flow_field(fl, X - cx + (L + 1) / 2, Y - cy + (L + 1) / 2);
        inside = abs(X - cx) <= half & abs(Y - cy) <= half;
        scale = flow.InPlane / max(hypot(U(inside), V(inside)));
        U = U * scale;
        V = V * scale;
    otherwise
        error('simulate:recording_3d:flow', 'Unknown flow type "%s".', flow.Type);
end
W = zeros(size(X)) + flow.OutOfPlane;
end

function truth = ground_truth(setup, g, X, Y, U, V, W)
truth.description = ['Ground truth of simulate.recording_3d. Displacement per image pair in mm. ' ...
    'X, Y, U, V, W: sheet coordinates (the light sheet is the plane z = 0, sheet_pose moves it to the world). ' ...
    'Xw, Yw, Zw, Uw, Vw, Ww: the same points and displacements in world = board coordinates ' ...
    '(origin first inner corner, x right, y down, z into the board). ' ...
    'simulate.truth_at_board(truth, x, y) gives U, V, W at board positions as a stereo-PIV result shows them.'];
truth.X = X;
truth.Y = Y;
truth.U = U;
truth.V = V;
truth.W = W;
truth.sheet_pose = g.sheet_pose;
truth.sheet_pose_matrix = g.sheet_pose.A;
P = transformPointsForward(g.sheet_pose, [X(:), Y(:), zeros(numel(X), 1)]);
truth.Xw = reshape(P(:, 1), size(X));
truth.Yw = reshape(P(:, 2), size(X));
truth.Zw = reshape(P(:, 3), size(X));
R = g.sheet_pose.R;
truth.Uw = R(1, 1) * U + R(1, 2) * V + R(1, 3) * W;
truth.Vw = R(2, 1) * U + R(2, 2) * V + R(2, 3) * W;
truth.Ww = R(3, 1) * U + R(3, 2) * V + R(3, 3) * W;
truth.cameras = cell(1, numel(g.cams));
for k = 1:numel(g.cams)
    cam = g.cams{k};
    truth.cameras{k} = struct('intrinsics', cam.intrinsics, 'pose', cam.pose, 'position', g.centre(k, :), ...
        'K', cam.intrinsics.K, 'RadialDistortion', cam.intrinsics.RadialDistortion, 'ImageSize', cam.imageSize);
end
truth.board = setup.board;
truth.sheet = setup.sheet;
truth.flow = setup.flow;
[ox, oy] = boundary(g.overlap);
truth.overlap = [ox, oy];
truth.region = g.region;
end

function write_readme(file, setup, g, truth)
n = numel(g.cams);
fid = fopen(file, 'w');
closer = onCleanup(@() fclose(fid));
p = @(varargin) fprintf(fid, [varargin{1} '\r\n'], varargin{2:end});
p('PIVlab synthetic %s recording (3D particle image generator), %s', ternary(n > 1, 'stereo-PIV', 'single camera'), char(datetime('now')));
p('');
p('World coordinates = board coordinates in mm: origin at the first inner corner of the ChArUco board,');
p('x right (columns), y down (rows), z into the board. Displacements in mm per image pair.');
p('');
p('Board: %d x %d checkers, %g mm checkers, %g mm markers, %s, origin checker %s', setup.board.PatternDims, ...
    setup.board.CheckerSize, setup.board.MarkerSize, char(setup.board.MarkerFamily), char(setup.board.OriginCheckerColor));
p('Sensor: %d x %d px, %g um pixels, lens %g mm', setup.sensor.ImageSize([2 1]), setup.sensor.PixelPitch, setup.sensor.FocalLength);
for k = 1:n
    p('Camera %d: position [%g %g %g] mm, aim point [%g %g] mm, radial distortion k1 = %g, k2 = %g', k, ...
        setup.cameras(k).Position, setup.cameras(k).Target, setup.cameras(k).RadialDistortion);
end
p('Light sheet: offset %g mm (towards camera 1), tilt %g deg about x, %g deg about y, thickness %g mm', ...
    setup.sheet.Offset, setup.sheet.TiltX, setup.sheet.TiltY, setup.sheet.Thickness);
p('Flow: %s, in-plane %g mm, radius %g mm, out-of-plane %g mm', setup.flow.Type, setup.flow.InPlane, setup.flow.Radius, setup.flow.OutOfPlane);
p('Particles: %g per pixel, diameter %g px (+-%g), noise %g', setup.particles.Density, setup.particles.Diameter, ...
    setup.particles.DiameterVariation, setup.particles.Noise);
p('');
p('Contents (k = camera number)');
p('  camera<k>/particle_images/       %d image pairs per camera (cam<k>_0001_A.tif, cam<k>_0001_B.tif, ...)', setup.output.Pairs);
p('  camera<k>/calibration_images/    %d images of the board in random positions (lens calibration)', setup.output.CalibrationImages);
p('  camera<k>/board_in_light_sheet_cam<k>.tif   board where the light sheet is (stereo calibration / rectification)');
p('  camera<k>/true_lens_cam<k>.mat   the true lens ("Load camera parameters"), to compare with the calibration');
p('  ground_truth.mat                 variable truth: displacement field and geometry');
p('  generator_setup.mat              variable setup: input of simulate.recording_3d');
p('');
p('Workflow in PIVlab');
p('  1. Image settings -> Camera calibration -> Camera calibration (undistortion) -> Camera <k>:');
p('     load the calibration images of camera <k> and estimate the camera parameters.');
if n > 1
    p('  2. Input data: "Import stereo images": the particle images of camera 1 and camera 2.');
    p('  3. Image rectification -> Camera <k>: load board_in_light_sheet_cam<k>.tif as target image.');
    p('  4. Analysis -> Stereo-PIV: compute the stereo calibration, measure the disparity, analyze.');
    p('     The light sheet is offset by %g mm and tilted: the disparity correction has to find it.', setup.sheet.Offset);
    p('  5. Compare with the ground truth: simulate.truth_at_board(truth, x_mm, y_mm).');
else
    p('  2. Load the particle images, rectify with board_in_light_sheet_cam1.tif, analyze.');
end
p('');
report = simulate.geometry_report_3d(g, setup.board);
for k = 1:numel(report)
    p('%s', report{k});
end
p('');
p('%s', truth.description);
end

function out = ternary(c, a, b)
if c
    out = a;
else
    out = b;
end
end

function R = rot_x(a)
R = [1 0 0; 0 cosd(a) -sind(a); 0 sind(a) cosd(a)];
end

function R = rot_y(a)
R = [cosd(a) 0 sind(a); 0 1 0; -sind(a) 0 cosd(a)];
end

function R = rot_z(a)
R = [cosd(a) -sind(a) 0; sind(a) cosd(a) 0; 0 0 1];
end
