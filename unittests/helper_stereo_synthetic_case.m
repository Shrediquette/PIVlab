function c = helper_stereo_synthetic_case(folder, n_pairs, static_pattern, layout)
%HELPER_STEREO_SYNTHETIC_CASE Small synthetic stereo-PIV recording with known displacement (for the unit tests).
%   c = helper_stereo_synthetic_case(folder, n_pairs, static_pattern)
%   c = helper_stereo_synthetic_case(folder, n_pairs, static_pattern, layout)
% Two pinhole cameras at about +-35 deg with lens distortion, 1024 x 1024 px, about 0.1 mm/px; a vortex
% with an out-of-plane jet; light sheet 1 mm in front of the board and tilted by 1 deg. static_pattern = 1
% adds bright static structures (reflections). layout: 'side' (default, cameras left and right),
% 'vertical' (camera 1 above camera 2), 'opposite' (camera 2 behind the board, on the other side of the
% light sheet: it sees the board mirrored, like a transparent board). Writes the images
% (cam1_0001_A.tif, ...) and the board images (board_cam1.tif, board_cam2.tif) to folder.
% c.files{k} image files of camera k, c.boards{k} board image, c.lens{k} cameraParameters (truth),
% c.board board definition, c.cams, c.sheet_pose, c.X, c.Y, c.U, c.V, c.W ground truth (sheet coordinates, mm).
if nargin < 4
    layout = 'side';
end
if ~isfolder(folder)
    mkdir(folder);
end
rng(0, 'twister'); % reproducible board image noise
sz = [1024 1024];
switch layout
    case 'side'
        pos = [-320 20 -440; 330 -10 -430];
    case 'vertical'
        pos = [60 -330 -440; 100 410 -430];
    case 'opposite'
        pos = [-320 20 -440; -290 -10 430];
    otherwise
        error('helper_stereo_synthetic_case: unknown layout %s', layout);
end
rad = [-0.06 0.02; -0.04 0.01];
cams = cell(1, 2);
for k = 1:2
    cams{k} = simulate.camera(ImageSize=sz, FocalLength=5600, Position=pos(k, :), Target=[80 70 0], RadialDistortion=rad(k, :));
end
board = struct('PatternDims', [18 20], 'CheckerSize', 10, 'MarkerSize', 7, 'MarkerFamily', "DICT_4X4_1000", ...
    'OriginCheckerColor', "black");
sheet_pose = rigidtform3d([1 0 0], [0 0 -1]); % 1 mm in front of the board, tilted 1 deg
box = [inf -inf inf -inf];
overlap = [-inf inf -inf inf];
area = 0;
for k = 1:2
    xy = simulate.footprint(cams{k}, sheet_pose);
    if k == 1
        area = polyarea(xy(:, 1), xy(:, 2));
    end
    b = [min(xy(:, 1)), max(xy(:, 1)), min(xy(:, 2)), max(xy(:, 2))];
    box = [min(box(1), b(1)), max(box(2), b(2)), min(box(3), b(3)), max(box(4), b(4))];
    overlap = [max(overlap(1), b(1)), min(overlap(2), b(2)), max(overlap(3), b(3)), min(overlap(4), b(4))];
end
fl.type = 'vortex_jet'; fl.v0 = 0.4; fl.R0 = 20; fl.c1 = [mean(overlap(1:2)) mean(overlap(3:4))]; fl.w_max = 0.25;
[X, Y] = meshgrid(box(1):1:box(2) + 1, box(3):1:box(4) + 1);
[U, V, W] = simulate.flow_field(fl, X, Y);
n_particles = round(0.05 * prod(sz) * (box(2) - box(1)) * (box(4) - box(3)) / area);
pattern = cell(1, 2);
for k = 1:2
    pattern{k} = zeros(sz, 'uint8');
    if static_pattern
        [xx, yy] = meshgrid(1:sz(2), 1:sz(1));
        pattern{k} = uint8(70 * exp(-((xx - 300 - 200 * k) .^ 2 + (yy - 500) .^ 2) / 60 ^ 2) + 40 * (abs(yy - 200 - 100 * k) < 6));
    end
end
c.files = {strings(0), strings(0)};
c.boards = cell(1, 2);
c.lens = cell(1, 2);
for k = 1:2
    I = simulate.charuco_image(cams{k}, PatternDims=board.PatternDims, CheckerSize=board.CheckerSize, ...
        MarkerSize=board.MarkerSize, MarkerFamily=board.MarkerFamily, OriginCheckerColor=board.OriginCheckerColor, ...
        Blur=1, Noise=0.001);
    c.boards{k} = fullfile(folder, sprintf('board_cam%d.tif', k));
    imwrite(I, c.boards{k});
    intr = cams{k}.intrinsics;
    c.lens{k} = cameraParameters(K=intr.K, RadialDistortion=intr.RadialDistortion, ...
        TangentialDistortion=intr.TangentialDistortion, ImageSize=sz);
end
for n = 1:n_pairs
    out = simulate.particle_images(Cameras=cams, Region=box, X=X, Y=Y, U=U, V=V, W=W, Particles=n_particles, ...
        SheetThickness=1.5, SheetPose=sheet_pose, Diameter=3, DiameterVariation=0.5, Noise=0.001, Seed=n);
    for k = 1:2
        fa = fullfile(folder, sprintf('cam%d_%04d_A.tif', k, n));
        fb = fullfile(folder, sprintf('cam%d_%04d_B.tif', k, n));
        imwrite(out.A{k} + pattern{k}, fa);
        imwrite(out.B{k} + pattern{k}, fb);
        c.files{k}(end + 1) = fa;
        c.files{k}(end + 1) = fb;
    end
end
c.cams = cams;
c.board = board;
c.sheet_pose = sheet_pose;
c.X = X; c.Y = Y; c.U = U; c.V = V; c.W = W;
end
