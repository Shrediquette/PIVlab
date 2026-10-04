function cam = camera(opts)
% Camera model for the synthetic image generator.
%
% Orthographic (default, the classic 2D case, no Computer Vision Toolbox needed):
%   cam = simulate.camera(ImageSize=[800 800])
%   pixel = (world_xy - Origin) * Scale, the world z coordinate is ignored.
%
% Pinhole camera with lens distortion, placed by position and viewing target:
%   cam = simulate.camera(ImageSize=[2048 2048], FocalLength=8000, ...
%                         Position=[-300 100 -430], Target=[100 100 0])
%
% Pinhole camera from a real calibration (e.g. PIVlab camera calibration):
%   cam = simulate.camera(Intrinsics=cameraParams.Intrinsics, Pose=camExtrinsics)
%
% World coordinates follow the MATLAB calibration board convention:
% x right, y down, z into the board. Pose transforms world to camera
% coordinates (as returned by estimateExtrinsics).
arguments
    opts.ImageSize (1,2) double = [800 800]  % [height width] in pixels
    opts.Scale (1,1) double = 1              % orthographic: pixels per world unit
    opts.Origin (1,2) double = [0 0]         % orthographic: world x,y at pixel coordinate 0
    opts.FocalLength double = []             % pinhole: focal length in pixels, scalar or [fx fy]
    opts.PrincipalPoint double = []          % pinhole: default = image centre
    opts.RadialDistortion double = [0 0]     % pinhole: radial distortion coefficients
    opts.Position double = []                % pinhole: camera centre in world coordinates
    opts.Target (1,3) double = [0 0 0]       % pinhole: world point on the optical axis
    opts.Up (1,3) double = [0 -1 0]          % pinhole: world direction that appears up in the image
    opts.Intrinsics = []                     % pinhole: cameraIntrinsics object
    opts.Pose = []                           % pinhole: rigidtform3d, world -> camera
end

if isempty(opts.Intrinsics) && isempty(opts.FocalLength)
    cam.type = 'ortho';
    cam.imageSize = opts.ImageSize;
    cam.scale = opts.Scale;
    cam.origin = opts.Origin;
    return
end

cam.type = 'pinhole';
if isempty(opts.Intrinsics)
    f = opts.FocalLength .* [1 1];
    pp = opts.PrincipalPoint;
    if isempty(pp)
        pp = (opts.ImageSize([2 1]) + 1) / 2;
    end
    cam.intrinsics = cameraIntrinsics(f, pp, opts.ImageSize, 'RadialDistortion', opts.RadialDistortion);
else
    cam.intrinsics = opts.Intrinsics;
end
cam.imageSize = cam.intrinsics.ImageSize;

if isempty(opts.Pose)
    if isempty(opts.Position)
        error('simulate:camera:noPose', 'A pinhole camera needs either Pose or Position.')
    end
    % look-at: camera z = viewing direction, camera y = image down, camera x = image right
    C = opts.Position(:);
    zc = opts.Target(:) - C;
    zc = zc / norm(zc);
    yc = -(opts.Up(:) - (opts.Up(:)' * zc) * zc);
    yc = yc / norm(yc);
    xc = cross(yc, zc);
    R = [xc'; yc'; zc'];
    cam.pose = rigidtform3d(R, -R * C);
else
    cam.pose = opts.Pose;
end
end
