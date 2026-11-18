function T = helper_truth_stereo_field(x, y, calib, c)
%HELPER_TRUTH_STEREO_FIELD True field of helper_stereo_synthetic_case on a stereo-PIV vector grid, in the
%   form of helper_truth_field (px per frame of the common grid): U right, V up on the screen, w away
%   from camera 1, gradients by central differences of the true field.
%   x, y   vector positions in px of the common (rectified) grid (res.px.x or resultslist rows 1, 2)
%   calib  stereo calibration (res.stereo.calib or gui.retr('stereo_calib'))
%   c      helper_stereo_synthetic_case
x = double(x);
y = double(y);
[x_mm, y_mm] = intrinsicToWorld(calib.Ravg, x, y);   % as stereo.reconstruct
flip = 1;
if calib.board_from_behind(1)
    flip = -1;
end
[Ut, Vt, Wt] = helper_stereo_truth_maps(x_mm, y_mm, c, flip);
mm = [calib.Ravg.PixelExtentInWorldX, calib.Ravg.PixelExtentInWorldY];
T.U = Ut / mm(1);            % board x = image x (to the right)
T.V = -Vt / mm(2);           % board y = image y (downward)
T.u = T.U;
T.v = -T.V;
T.w = Wt / mm(1);            % away from camera 1
step = x(1, 2) - x(1, 1);
[ux, uy_img] = gradient(T.U, step, step);
[vx, vy_img] = gradient(T.V, step, step);
T.ux = ux;
T.uy = -uy_img;              % Y up
T.vx = vx;
T.vy = -vy_img;
end
