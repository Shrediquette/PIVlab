function c = helper_fov_synthetic_case(folder, n_pairs, opts)
%HELPER_FOV_SYNTHETIC_CASE Two cameras side by side for a larger field of view, with known displacement (unit tests).
%   c = helper_fov_synthetic_case(folder, n_pairs)
%   c = helper_fov_synthetic_case(folder, n_pairs, Name=Value)
% Two pinhole cameras perpendicular to the light sheet, side by side (x), 1024 x 1024 px, about 0.09 mm/px,
% with lens distortion. One ChArUco board in the light sheet over both views (checkers 10 mm, about 112 px).
% A vortex centred near the seam (in-plane only, w = 0), displacements up to about 3 px.
%   Separation  [mm] distance of the cameras along x (default 80: overlap ~11 mm, ~125 px, ~12 %)
%   SheetOffset [mm] light sheet behind the board (default 0)
%   SheetTilt   [deg] light sheet turned about the x axis (z changes along y, i.e. along the seam; default 0)
%   Static      true: bright static structures (reflections) in both cameras (default false)
% Writes cam1_0001_A.tif, ..., board_cam1.tif, board_cam2.tif to folder.
% c.files{k}, c.boards{k}, c.lens{k} (cameraParameters, truth), c.board, c.cams, c.sheet_pose,
% c.X, c.Y, c.U, c.V ground truth (board = sheet coordinates, mm, x right, y down as in the images).
arguments
    folder
    n_pairs (1,1) double
    opts.Separation (1,1) double = 80
    opts.SheetOffset (1,1) double = 0
    opts.SheetTilt (1,1) double = 0
    opts.Static (1,1) logical = false
end
if ~isfolder(folder)
    mkdir(folder);
end
rng(0, 'twister'); % reproducible board image noise
sz = [1024 1024];
xc = 90 + [-1 1] * opts.Separation / 2;
yc = 50;
rad = [-0.06 0.02; -0.04 0.01];
cams = cell(1, 2);
for k = 1:2
    cams{k} = simulate.camera(ImageSize=sz, FocalLength=5600, Position=[xc(k) yc -500], Target=[xc(k) yc 0], ...
        RadialDistortion=rad(k, :));
end
board = struct('PatternDims', [13 20], 'CheckerSize', 10, 'MarkerSize', 7, 'MarkerFamily', "DICT_4X4_1000", ...
    'OriginCheckerColor', "black");
sheet_pose = rigidtform3d([opts.SheetTilt 0 0], [0 0 opts.SheetOffset]);
box = [inf -inf inf -inf];
area1 = 0;
for k = 1:2
    xy = simulate.footprint(cams{k}, sheet_pose);
    if k == 1
        area1 = polyarea(xy(:, 1), xy(:, 2));
    end
    box = [min(box(1), min(xy(:, 1))), max(box(2), max(xy(:, 1))), min(box(3), min(xy(:, 2))), max(box(4), max(xy(:, 2)))];
end
fl.type = 'vortex_jet'; fl.v0 = 0.3; fl.R0 = 25; fl.c1 = [92 48]; fl.w_max = 0;
[X, Y] = meshgrid(floor(box(1)):0.5:ceil(box(2)) + 1, floor(box(3)):0.5:ceil(box(4)) + 1);
[U, V, W] = simulate.flow_field(fl, X, Y);
n_particles = round(0.05 * prod(sz) * (box(2) - box(1)) * (box(4) - box(3)) / area1);
pattern = cell(1, 2);
for k = 1:2
    pattern{k} = zeros(sz, 'uint8');
    if opts.Static
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
c.X = X; c.Y = Y; c.U = U; c.V = V;
end
