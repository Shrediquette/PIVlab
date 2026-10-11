function disparity = disparity_field(calib, x, y, u_mean_smooth, v_mean_smooth)
%DISPARITY_FIELD Full-size disparity maps from the disparity vectors (x, y, u, v on the PIV grid).
% The vector map is first extended to the image borders (linear, gaps filled with inpaint_nans),
% then interpolated to every pixel of calib.Ravg (as in the prototype, "deformation matrix" approach).
H = calib.Ravg.ImageSize(1);
W = calib.Ravg.ImageSize(2);
x_expand = [zeros(size(x, 1), 1) x ones(size(x, 1), 1) * W];
x_expand = [x_expand(1, :); x_expand; x_expand(1, :)];
y_expand = [zeros(1, size(y, 2)); y; ones(1, size(y, 2)) * H];
y_expand = [y_expand(:, 1) y_expand y_expand(:, 1)];
u_expand = interp2(x, y, double(u_mean_smooth), x_expand, y_expand, "linear", nan);
v_expand = interp2(x, y, double(v_mean_smooth), x_expand, y_expand, "linear", nan);
u_expand = misc.inpaint_nans(u_expand);
v_expand = misc.inpaint_nans(v_expand);
[xq, yq] = meshgrid(1:W, 1:H);
disparity.u_full = interp2(x_expand, y_expand, double(u_expand), xq, yq, "linear", 0);
disparity.v_full = interp2(x_expand, y_expand, double(v_expand), xq, yq, "linear", 0);
disparity.xq = xq;
disparity.yq = yq;
disparity.x = x;
disparity.y = y;
disparity.u_mean_smooth = u_mean_smooth;
disparity.v_mean_smooth = v_mean_smooth;
end
