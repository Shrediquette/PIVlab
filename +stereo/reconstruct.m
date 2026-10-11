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
%   AWAY from the cameras (into the board).
%   vel.residual [px]: 4 measured components, 3 unknowns - the remaining difference of the two
%   cameras (consistency, quality measure). vel.sheet_z_mm: light sheet position [mm], + = behind the
%   board. vel.mm_per_px: size of an output pixel [mm] (x, y).
%
% Per vector, the line of sight from each camera centre to the light sheet point gives the signed
% tangents ta_k, tb_k; a displacement (U, V, Wz) appears in camera k as
%   u_k = m_k * (U - Wz*ta_k),  v_k = m_k * (V - Wz*tb_k),  m_k = D_k / (z + D_k)
% with the sheet at z (from the disparity, z = d / (tan a1 - tan a2)), D_k the camera distance.
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

sheet_d = [];
if ~isempty(disparity) && opts.SheetFromDisparity
    sheet_d = interp2(disparity.u_full, x, y); % disparity at the vector positions [px]: where the sheet is
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

% world = board coordinates [mm], x right, y down, z into the board; camera k at C = (Xc, Yc, Zc), D = -Zc
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
if ~isempty(sheet_d)
    d_world = sheet_d * calib.Ravg.PixelExtentInWorldX; % disparity camera 1 -> camera 2 [mm]
    for it = 1:5 % fixed point: sheet position and tangents depend on each other
        z = d_world ./ (ta1 - ta2);
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
Wz = (u1 - u2) ./ (ta2 - ta1);
vel.U = (u1 .* ta2 - u2 .* ta1) ./ (ta2 - ta1);
vel.V = 0.5 * (v1 + v2) + 0.5 * Wz .* (tb1 + tb2);
vel.W = Wz; % positive away from the cameras
% the v equations are only used through their mean; their difference must vanish for matching views
vel.residual = (v1 - v2) + Wz .* (tb1 - tb2);
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
