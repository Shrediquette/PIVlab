function C = combine_cameras(R1, R2, calib, disparity, opts)
%COMBINE_CAMERAS U, V, W from the 2D results of both cameras (shared by the GUI and the API).
%   C = stereo.combine_cameras(R1, R2, calib, disparity)
%   C = stereo.combine_cameras(R1, R2, calib, disparity, opts)    opts: stereo.defaults().reconstruction
%   Rk         2D result of camera k on the common grid: x, y (vector grid), u, v, typevector
%              [rows x columns x image pairs] (validated or raw displacements in px per image pair) and
%              correlation (same size, or [])
%   disparity  the disparity correction (stereo.measure_disparity; the full-size maps are made again if missing)
%   C          x, y; U, V, W [px per image pair] (NaN where masked); typevector: 1 valid, 2 removed / replaced in
%              one of the cameras, 0 masked in one of the cameras; correlation: the smaller one of both cameras;
%              residual (NaN where masked); sheet_z_mm, mm_per_px, x_mm, y_mm (stereo.reconstruct)
% The GUI (stereo.reconstruct_results) and the API (pivlab.stereo, pivlab.filter, pivlab.loadSession) both use
% this function, so they give the same numbers.
if nargin < 5
    opts = [];
end
if ~isequal(size(R1.x), size(R2.x)) || size(R1.u, 3) ~= size(R2.u, 3)
    error('stereo:update_result', 'Both cameras must be analysed on the same grid (same region of interest and PIV settings).');
end
res = cell(1, 2);
R = {R1, R2};
for k = 1:2
    res{k}.px.x = R{k}.x;
    res{k}.px.y = R{k}.y;
    res{k}.px.u = double(R{k}.u);
    res{k}.px.v = double(R{k}.v);
    res{k}.px.u_smoothed = [];
    res{k}.px.v_smoothed = [];
end
vel = stereo.reconstruct(res{1}, res{2}, calib, stereo.full_disparity(calib, disparity), opts);
t1 = R1.typevector;
t2 = R2.typevector;
typevector = ones(size(t1));
typevector(t1 == 2 | t2 == 2) = 2; % removed (interpolated) in one of the cameras
typevector(t1 == 0 | t2 == 0) = 0; % masked in one of the cameras
masked = typevector == 0;
C.x = R1.x;
C.y = R1.y;
C.U = vel.U;
C.V = vel.V;
C.W = vel.W;
C.U(masked) = NaN;
C.V(masked) = NaN;
C.W(masked) = NaN;
C.typevector = typevector;
c1 = NaN(size(t1));
c2 = NaN(size(t1));
if isfield(R1, 'correlation') && isequal(size(R1.correlation), size(t1))
    c1 = R1.correlation;
end
if isfield(R2, 'correlation') && isequal(size(R2.correlation), size(t1))
    c2 = R2.correlation;
end
C.correlation = min(c1, c2);
C.residual = vel.residual;
C.residual(masked) = NaN;
C.sheet_z_mm = vel.sheet_z_mm;
C.mm_per_px = vel.mm_per_px;
C.x_mm = vel.x_mm;
C.y_mm = vel.y_mm;
end
