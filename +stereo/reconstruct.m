function vel = reconstruct(res1, res2, calib, disparity, opts)
%RECONSTRUCT Three velocity components from the PIV results of both cameras.
%   vel = stereo.reconstruct(res1, res2, calib, disparity)
%   vel = stereo.reconstruct(res1, res2, calib, disparity, opts)
%   res1, res2  PIV results of camera 1 and 2 (pivlab.analyze, pivlab.filter, optionally smoothed with
%               pivlab.derive) on the rectified, disparity-corrected images, same grid
%   calib       stereo.calibrate
%   disparity   stereo.measure_disparity ([] = sheet on the board, no disparity-gradient correction)
%   opts        stereo.defaults().reconstruction (SheetFromDisparity, DisparityGradient)
%
%   vel.U, vel.V, vel.W [rectified px per image pair, rows x columns x pairs], vel.x, vel.y [px].
%   Coordinates like PIVlab: x to the right, y down (rectified image), right-handed: W is positive
%   AWAY from camera 1 (into the board as seen from camera 1; with both cameras on the same side:
%   away from the cameras).
%   vel.residual [px]: 4 measured components, 3 unknowns - the part of the difference of the two
%   cameras that no 3D motion can explain (consistency, quality measure). vel.sheet_z_mm: light sheet
%   position [mm], + = behind the board (away from camera 1). vel.mm_per_px: size of an output pixel [mm] (x, y).
%
% Per vector, the line of sight from each camera centre to the light sheet point gives the signed
% tangents ta_k, tb_k; a displacement (U, V, Wz) appears in camera k as
%   u_k = m_k * (U - Wz*ta_k),  v_k = m_k * (V - Wz*tb_k),  m_k = D_k / (z + D_k)
% with the sheet at z and D_k the distance of camera k in front of the board (negative behind it).
% The difference of both cameras e = (u1/m1 - u2/m2, v1/m1 - v2/m2) = -Wz * dt points along the stereo
% direction dt = (ta1 - ta2, tb1 - tb2); the least-squares solution of the 4 equations is
%   Wz = -(e . dt) / |dt|^2,  U = mean(u/m) + Wz*mean(ta),  V = mean(v/m) + Wz*mean(tb)
% for any camera arrangement (side by side, above each other, on opposite sides of the sheet). The
% sheet position comes from the disparity d = z * dt in the same way: z = (d . dt) / |dt|^2.
if nargin < 5 || isempty(opts)
    def = stereo.defaults();
    opts = def.reconstruction;
end
x = double(res1.px.x);
y = double(res1.px.y);
if ~isequal(size(res2.px.x), size(x)) || any(abs(double(res2.px.x(:)) - x(:)) > 0) || any(abs(double(res2.px.y(:)) - y(:)) > 0)
    error('stereo:reconstruct', 'Both cameras must be analysed on the same grid (same region of interest and PIV settings).');
end
[u1, v1] = displacements(res1);
[u2, v2] = displacements(res2);
if size(u1, 3) ~= size(u2, 3)
    error('stereo:reconstruct', 'Both cameras must have the same number of image pairs.');
end

sheet_du = [];
if ~isempty(disparity) && opts.SheetFromDisparity
    sheet_du = interp2(disparity.u_full, x, y); % disparity at the vector positions [px]: where the sheet is
    sheet_dv = interp2(disparity.v_full, x, y);
end
if ~isempty(disparity) && opts.DisparityGradient
    % The PIV measures in the disparity-corrected images. Where the correction shift d varies, the
    % displacement there differs from the one in the rectified image: camera 1 (shifted by -d/2):
    % u = u' - 0.5*(grad d).u', camera 2 (+d/2): u = u' + 0.5*(grad d).u'
    dux = (interp2(disparity.u_full, x + 1, y) - interp2(disparity.u_full, x - 1, y)) / 2;
    duy = (interp2(disparity.u_full, x, y + 1) - interp2(disparity.u_full, x, y - 1)) / 2;
    dvx = (interp2(disparity.v_full, x + 1, y) - interp2(disparity.v_full, x - 1, y)) / 2;
    dvy = (interp2(disparity.v_full, x, y + 1) - interp2(disparity.v_full, x, y - 1)) / 2;
    u1c = u1 - 0.5 * (dux .* u1 + duy .* v1);
    v1c = v1 - 0.5 * (dvx .* u1 + dvy .* v1);
    u2c = u2 + 0.5 * (dux .* u2 + duy .* v2);
    v2c = v2 + 0.5 * (dvx .* u2 + dvy .* v2);
    u1 = u1c; v1 = v1c; u2 = u2c; v2 = v2c;
end

% world = board coordinates [mm], x right, y down, z into the board (away from camera 1); camera k at
% C = (Xc, Yc, Zc), D = -Zc (negative for a camera behind the board)
C1 = calib.centre(1, :);
C2 = calib.centre(2, :);
D1 = -C1(3);
D2 = -C2(3);
[xw, yw] = intrinsicToWorld(calib.Ravg, x, y);
z = zeros(size(xw));
xs = xw;
ys = yw;
ta1 = (xs - C1(1)) / D1; tb1 = (ys - C1(2)) / D1;
ta2 = (xs - C2(1)) / D2; tb2 = (ys - C2(2)) / D2;
if ~isempty(sheet_du)
    du_world = sheet_du * calib.Ravg.PixelExtentInWorldX; % disparity camera 1 -> camera 2 [mm]
    dv_world = sheet_dv * calib.Ravg.PixelExtentInWorldY;
    for it = 1:5 % fixed point: sheet position and tangents depend on each other
        dta = ta1 - ta2;
        dtb = tb1 - tb2;
        z = (du_world .* dta + dv_world .* dtb) ./ (dta .^ 2 + dtb .^ 2); % d = z * dt
        xs = xw + z .* (ta1 + ta2) / 2; % the vector at board position xw shows the sheet point between both views
        ys = yw + z .* (tb1 + tb2) / 2;
        ta1 = (xs - C1(1)) ./ (z + D1); tb1 = (ys - C1(2)) ./ (z + D1);
        ta2 = (xs - C2(1)) ./ (z + D2); tb2 = (ys - C2(2)) ./ (z + D2);
    end
end
m1 = D1 ./ (z + D1);
m2 = D2 ./ (z + D2);
u1 = u1 ./ m1; v1 = v1 ./ m1;
u2 = u2 ./ m2; v2 = v2 ./ m2;
% difference of both cameras along the stereo direction dt gives Wz, the rest is the residual
dta = ta1 - ta2;
dtb = tb1 - tb2;
dt2 = dta .^ 2 + dtb .^ 2;
ex = u1 - u2;
ey = v1 - v2;
Wz = -(ex .* dta + ey .* dtb) ./ dt2;
vel.U = 0.5 * (u1 + u2) + 0.5 * Wz .* (ta1 + ta2);
vel.V = 0.5 * (v1 + v2) + 0.5 * Wz .* (tb1 + tb2);
vel.W = Wz; % positive away from camera 1
% component of the camera difference perpendicular to dt: must vanish for matching views (sign: for
% cameras side by side with camera 1 on the left it is v1 - v2 corrected for Wz)
vel.residual = (ey .* dta - ex .* dtb) ./ sqrt(dt2);
vel.ta = cat(3, ta1, ta2);
vel.tb = cat(3, tb1, tb2);
vel.sheet_z_mm = z;
vel.x = x;
vel.y = y;
vel.x_mm = xw; % vector positions on the board [mm]
vel.y_mm = yw;
vel.mm_per_px = [calib.Ravg.PixelExtentInWorldX, calib.Ravg.PixelExtentInWorldY];
end

function [u, v] = displacements(res)
% validated (and smoothed, if pivlab.derive smoothed them) displacements in px per image pair
if isfield(res.px, 'u_smoothed') && ~isempty(res.px.u_smoothed)
    u = double(res.px.u_smoothed);
    v = double(res.px.v_smoothed);
else
    u = double(res.px.u);
    v = double(res.px.v);
end
end
