function g = geometry_3d(setup)
% Cameras, light sheet and views of the particle image generator (see simulate.setup_3d).
%   g = simulate.geometry_3d(setup)
%   g.simple      true for setup.Mode 'simple': one orthographic camera that looks straight at
%                 the light sheet (pixel = sheet position / PixelSize), no lens, sheet = board plane
%   g.cams        cell array of cameras (simulate.camera, pinhole with lens distortion / orthographic)
%   g.centre      camera centres (one row per camera) [mm] (simple: NaN)
%   g.sheet_pose  rigidtform3d, sheet coordinates -> world (board) coordinates
%   g.pivot       point of the sheet that Offset refers to (centre of the aim points, on the board)
%   g.views       polyshape per camera: field of view on the sheet (sheet coordinates)
%   g.overlap     polyshape: seen by all cameras (sheet coordinates)
%   g.region      [xmin xmax ymin ymax] bounding box of all views (sheet coordinates)
%   g.ok, g.message   false and a reason if a camera does not see the light sheet
g.simple = strcmp(setup.Mode, 'simple');
if g.simple
    if ~(setup.Simple.PixelSize > 0)
        error('simulate:geometry_3d:pixel', 'The pixel size in the light sheet must be positive.');
    end
    g.cams = {simulate.camera(ImageSize=setup.sensor.ImageSize, Scale=1 / setup.Simple.PixelSize)};
    g.centre = [NaN NaN NaN];
    g.ok = true;
    g.message = '';
    g.pivot = [0 0 0];
    g.sheet_pose = rigidtform3d;
    xy = simulate.footprint(g.cams{1}, g.sheet_pose);
    warning('off', 'MATLAB:polyshape:repairedBySimplify');
    g.views = polyshape(xy(:, 1), xy(:, 2));
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
    g.overlap = g.views;
    g.region = [min(xy(:, 1)) max(xy(:, 1)) min(xy(:, 2)) max(xy(:, 2))];
    return
end
n = numel(setup.cameras);
f_px = setup.sensor.FocalLength / (setup.sensor.PixelPitch / 1000);
g.cams = cell(1, n);
g.centre = zeros(n, 3);
g.ok = true;
g.message = '';
for k = 1:n
    C = setup.cameras(k).Position;
    T = [setup.cameras(k).Target 0];
    if norm(T - C) < 1e-9
        error('simulate:geometry_3d:target', 'Camera %d: the aim point must not be the camera position.', k);
    end
    up = [0 -1 0]; % image up = board up (-y), unless the camera looks along y
    if abs(dot((T - C) / norm(T - C), up)) > 0.98
        up = [0 0 -1];
    end
    g.cams{k} = simulate.camera(ImageSize=setup.sensor.ImageSize, FocalLength=f_px, Position=C, Target=T, Up=up, ...
        RadialDistortion=setup.cameras(k).RadialDistortion);
    g.centre(k, :) = C;
end

%% light sheet: tilted about the centre of the aim points, moved along the board normal
targets = reshape([setup.cameras.Target], 2, []);
g.pivot = [mean(targets, 2)' 0];
side = sign(g.centre(1, 3)); % offset > 0: towards camera 1 (z < 0 for a camera in front of the board)
if side == 0
    side = -1;
end
R = rotm(setup.sheet.TiltX, setup.sheet.TiltY);
t = g.pivot(:) + [0; 0; side * setup.sheet.Offset] - R * g.pivot(:);
g.sheet_pose = rigidtform3d(R, t');

%% views of the cameras on the sheet
g.views = repmat(polyshape(), 1, n);
for k = 1:n
    xy = simulate.footprint(g.cams{k}, g.sheet_pose);
    if size(xy, 1) < 80 % some rays of the image border do not hit the sheet in front of the camera (simulate.footprint: 80 points)
        g.ok = false;
        g.message = sprintf('Camera %d does not see the whole light sheet plane in its image (it looks past it).', k);
        continue
    end
    warning('off', 'MATLAB:polyshape:repairedBySimplify');
    g.views(k) = polyshape(xy(:, 1), xy(:, 2));
    warning('on', 'MATLAB:polyshape:repairedBySimplify');
end
g.overlap = g.views(1);
for k = 2:n
    g.overlap = intersect(g.overlap, g.views(k));
end
[x, y] = boundary(union(g.views));
if isempty(x)
    g.region = [0 1 0 1];
else
    g.region = [min(x) max(x) min(y) max(y)];
end
if g.ok && n > 1 && area(g.overlap) <= 0
    g.ok = false;
    g.message = 'The views of the cameras do not overlap on the light sheet.';
end
end

function R = rotm(ax, ay)
% rotation about the board x axis, then about the board y axis (degrees)
Rx = [1 0 0; 0 cosd(ax) -sind(ax); 0 sind(ax) cosd(ax)];
Ry = [cosd(ay) 0 sind(ay); 0 1 0; -sind(ay) 0 cosd(ay)];
R = Ry * Rx;
end
