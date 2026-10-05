function out = particle_images(opts)
% Synthetic PIV particle image pairs with known displacement.
% Particles are seeded in 3D around a Gaussian laser sheet, moved by a
% displacement field and imaged by one or more cameras (see simulate.camera).
%
% The displacement field is given on a grid (X, Y from meshgrid, uniformly
% spaced) with the displacements U, V and optionally W (out-of-plane). Any
% field can be used: an analytic flow (see simulate.flow_field), a CFD
% result or a measured PIV field. It is interpolated at the particle
% positions; beyond the grid, the values at the grid edge are continued.
%
% Classic 2D case (orthographic camera, units = pixels):
%   [X, Y] = meshgrid(1:800, 1:800);
%   flow.type = 'rankine'; flow.v0 = 5; flow.R0 = 50; flow.c1 = [400 400]; flow.double = false;
%   [U, V] = simulate.flow_field(flow, X, Y);
%   out = simulate.particle_images(ImageSize=[800 800], Particles=200000, X=X, Y=Y, U=U, V=V);
%   A = out.A{1}; B = out.B{1};
%
% Stereo case (pinhole cameras, units = world units, e.g. mm):
%   [X, Y] = meshgrid(0:200, 0:150);
%   U = zeros(size(X));
%   V = zeros(size(X));
%   W = zeros(size(X)) + 0.2;
%   out = simulate.particle_images(Cameras={cam1, cam2}, Region=[0 200 0 150], ...
%           SheetThickness=1.5, Diameter=3, X=X, Y=Y, U=U, V=V, W=W);
%
% The grid is in sheet coordinates: the sheet is the plane z = 0 of the
% sheet coordinates; SheetPose moves it in the world (board) coordinates.
% Particle positions in image B are the positions in image A plus the
% displacement at the image A positions.
%
% Output struct:
%   A, B       cell arrays (one per camera) of uint8 images
%   particles  sheet coordinates of the particles in image A and B (N-by-3),
%              particle image diameter d [px] and intensities IA, IB [counts]
%   region     seeding area [xmin xmax ymin ymax] without margin
arguments
    opts.Cameras = {}                       % cell array of cameras; default: orthographic camera of ImageSize
    opts.ImageSize (1,2) double = [800 800] % [height width], only used for the default camera
    opts.X double = []                      % grid of the displacement field (meshgrid), sheet coordinates
    opts.Y double = []
    opts.U double = []                      % displacement on the grid; default: no motion
    opts.V double = []
    opts.W double = []                      % out-of-plane displacement on the grid; default: 0
    opts.Particles (1,1) double = 200000    % number of particles in Region inside +-SheetThickness
    opts.Region double = []                 % [xmin xmax ymin ymax] in sheet coordinates; default: field of view of the cameras
    opts.Diameter (1,1) double = 3          % mean particle image diameter [px] (e^-2 intensity)
    opts.DiameterVariation (1,1) double = 1 % particle diameter variation, std = DiameterVariation/2 [px]
    opts.SheetThickness (1,1) double = 1    % laser sheet thickness (e^-2 intensity) in world units
    opts.SheetPose = []                     % rigidtform3d, sheet -> world; default: identity
    opts.PeakIntensity (1,1) double = 255   % intensity of a particle in the sheet centre [counts]
    opts.Noise (1,1) double = 0             % Gaussian noise variance as in imnoise (0 = no noise)
    opts.Seed double = []                   % random number seed for reproducible images
end
cams = opts.Cameras;
if isempty(cams)
    cams = {simulate.camera(ImageSize=opts.ImageSize)};
end
sheetPose = opts.SheetPose;
if isempty(sheetPose)
    sheetPose = rigidtform3d;
end
if ~isempty(opts.Seed)
    previous_rng = rng(opts.Seed); % restored at the end
end

%% Seeding volume: region of interest plus a margin, so that no empty strips appear
region = opts.Region;
if isempty(region) % bounding box of the camera fields of view on the sheet
    xy = zeros(0, 2);
    for k = 1:numel(cams)
        xy = [xy; simulate.footprint(cams{k}, sheetPose)]; %#ok<AGROW>
    end
    region = [min(xy(:, 1)), max(xy(:, 1)), min(xy(:, 2)), max(xy(:, 2))];
end
max_inplane = max([hypot(opts.U(:), opts.V(:)); 0]);
max_w = max([abs(opts.W(:)); 0]);
margin = 1.2 * max_inplane + 0.03 * max(region(2) - region(1), region(4) - region(3));
dz = opts.SheetThickness;
zlim = dz + 1.2 * max_w; % particles beyond +-dz are practically invisible (< e^-8)
box = [region(1) - margin, region(2) + margin, region(3) - margin, region(4) + margin];
area_ratio = (box(2) - box(1)) * (box(4) - box(3)) / ((region(2) - region(1)) * (region(4) - region(3)));
n = round(opts.Particles * area_ratio * zlim / dz);

%% Particles and their motion
PA = [box(1) + rand(n, 1) * (box(2) - box(1)), box(3) + rand(n, 1) * (box(4) - box(3)), (2 * rand(n, 1) - 1) * zlim];
u = displacement_at(opts.X, opts.Y, opts.U, PA(:, 1), PA(:, 2));
v = displacement_at(opts.X, opts.Y, opts.V, PA(:, 1), PA(:, 2));
w = displacement_at(opts.X, opts.Y, opts.W, PA(:, 1), PA(:, 2));
PB = PA + [u, v, w];
d = max(opts.Diameter + randn(n, 1) / 2 * opts.DiameterVariation, 0.5);
IA = opts.PeakIntensity * exp(-8 * PA(:, 3).^2 / dz^2);
IB = opts.PeakIntensity * exp(-8 * PB(:, 3).^2 / dz^2);

%% Image every visible particle with every camera
visA = IA >= 0.5; % dimmer particles vanish when the image is rounded to integers
visB = IB >= 0.5;
WA = transformPointsForward(sheetPose, PA(visA, :));
WB = transformPointsForward(sheetPose, PB(visB, :));
out.A = cell(1, numel(cams));
out.B = cell(1, numel(cams));
for k = 1:numel(cams)
    cam = cams{k};
    out.A{k} = finish(render(simulate.project(cam, WA), d(visA), IA(visA), cam.imageSize), opts.Noise);
    out.B{k} = finish(render(simulate.project(cam, WB), d(visB), IB(visB), cam.imageSize), opts.Noise);
end
out.particles = struct('A', PA, 'B', PB, 'd', d, 'IA', IA, 'IB', IB);
out.region = region;
if ~isempty(opts.Seed)
    rng(previous_rng);
end
end

function f = displacement_at(X, Y, F, xq, yq)
% displacement F (given on the grid X, Y) at the points xq, yq;
% beyond the grid, the values at the grid edge are continued
if isempty(F)
    f = zeros(size(xq));
    return
end
xq = min(max(xq, min(X(:))), max(X(:)));
yq = min(max(yq, min(Y(:))), max(Y(:)));
if min(size(F)) >= 4
    f = interp2(X, Y, F, xq, yq, 'cubic');
else
    f = interp2(X, Y, F, xq, yq, 'linear'); % cubic needs at least 4 grid points in each direction
end
end

function img = render(xy, d, I, imageSize)
% Gaussian particle images (diameter d at e^-2), integrated over the pixel
% area, so that small particles keep their correct intensity centroid.
sigma = d / 4;
r = max(1, ceil(3 * sigma - 0.5)); % stencil radius: omitted pixels are > 3 sigma away (< 1.1 % of the peak)
keep = all(xy > 0.5 - r & xy < imageSize([2 1]) + 0.5 + r, 2); % particles that touch the image
pad = 2 * max([r(keep); 0]); % render into a padded canvas, so no stencil pixel falls outside
canvas = imageSize + 2 * pad;
img = zeros(canvas);
for radius = unique(r(keep))' % particles with the same stencil size are processed together
    sel = keep & r == radius;
    x = xy(sel, 1);
    y = xy(sel, 2);
    s = sigma(sel);
    offsets = -radius:radius;
    m = numel(x);
    k = numel(offsets);
    wy = pixel_integral(round(y), offsets, y, s) .* I(sel);
    wx = pixel_integral(round(x), offsets, x, s);
    rows = reshape(round(y) + offsets + pad, m, k, 1);
    cols = reshape(round(x) + offsets + pad, m, 1, k);
    lin = rows + (cols - 1) * canvas(1);
    val = reshape(wy, m, k, 1) .* reshape(wx, m, 1, k);
    img(:) = img(:) + accumarray(lin(:), val(:), [prod(canvas) 1]);
end
img = img(pad + 1:pad + imageSize(1), pad + 1:pad + imageSize(2));
end

function w = pixel_integral(p0, offsets, c, s)
% integral of exp(-(t-c)^2 / (2 s^2)) over the pixels p0 + offsets, i.e.
% [p-0.5, p+0.5] (equals the point-sampled Gaussian for large particles);
% erf is evaluated once per pixel edge
edges = p0 + [offsets - 0.5, offsets(end) + 0.5];
w = s * sqrt(pi / 2) .* diff(erf((edges - c) ./ (sqrt(2) * s)), 1, 2);
end

function img = finish(img, noise)
img = uint8(img); % rounds and clips to 0..255
if noise > 0
    img = imnoise(img, 'gaussian', 0, noise);
end
end
