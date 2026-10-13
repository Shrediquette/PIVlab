function sheet = sheet_position(calib, disparity)
%SHEET_POSITION Position of the light sheet relative to the board, from the disparity.
%   sheet = stereo.sheet_position(calib, disparity)
%   sheet.x, sheet.y, sheet.z  board coordinates [mm] of the light sheet at the points of the disparity
%                              grid (z > 0: behind the board, away from camera 1)
%   sheet.offset               z [mm] at the centre of the overlap of both views
%   sheet.tilt                 [about the y axis, about the x axis] [deg] of a plane fitted to z
%   sheet.unexplained_mm       rms [mm] of the disparity part that no sheet position can explain
%                              (perpendicular to the stereo direction: calibration errors, board moved)
% A particle in the sheet at height z is seen by both cameras at board positions that differ by
% d = z * dt, dt = (ta1 - ta2, tb1 - tb2) (signed tangents of the lines of sight), so
% z = (d . dt) / |dt|^2 for any camera arrangement; see stereo.reconstruct.
[xw, yw] = intrinsicToWorld(calib.Ravg, double(disparity.x), double(disparity.y));
du = double(disparity.u_mean_smooth) * calib.Ravg.PixelExtentInWorldX;
dv = double(disparity.v_mean_smooth) * calib.Ravg.PixelExtentInWorldY;
C1 = calib.centre(1, :);
C2 = calib.centre(2, :);
D1 = -C1(3);
D2 = -C2(3);
z = zeros(size(xw));
xs = xw;
ys = yw;
ta1 = (xs - C1(1)) / D1; tb1 = (ys - C1(2)) / D1;
ta2 = (xs - C2(1)) / D2; tb2 = (ys - C2(2)) / D2;
for it = 1:5 % fixed point: sheet position and tangents depend on each other (as in stereo.reconstruct)
    dta = ta1 - ta2;
    dtb = tb1 - tb2;
    z = (du .* dta + dv .* dtb) ./ (dta .^ 2 + dtb .^ 2);
    xs = xw + z .* (ta1 + ta2) / 2;
    ys = yw + z .* (tb1 + tb2) / 2;
    ta1 = (xs - C1(1)) ./ (z + D1); tb1 = (ys - C1(2)) ./ (z + D1);
    ta2 = (xs - C2(1)) ./ (z + D2); tb2 = (ys - C2(2)) ./ (z + D2);
end
dta = ta1 - ta2;
dtb = tb1 - tb2;
perp = (dv .* dta - du .* dtb) ./ sqrt(dta .^ 2 + dtb .^ 2);
sheet.x = xs;
sheet.y = ys;
sheet.z = z;
inside = isinterior(calib.grid_info.overlap, xs(:), ys(:)) & isfinite(z(:));
A = [ones(nnz(inside), 1), xs(inside), ys(inside)];
coef = A \ z(inside);
[cx, cy] = centroid(calib.grid_info.overlap);
sheet.offset = coef(1) + coef(2) * cx + coef(3) * cy;
sheet.tilt = [atand(coef(2)), atand(coef(3))];
sheet.unexplained_mm = sqrt(mean(perp(inside) .^ 2));
end
