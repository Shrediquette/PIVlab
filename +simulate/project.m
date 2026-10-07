function pix = project(cam, P)
% Project world points P (N-by-3) into the image of camera cam (see
% simulate.camera). Returns N-by-2 pixel coordinates [x y], pixel centres at 1..n.
if strcmp(cam.type, 'ortho')
    pix = (P(:, 1:2) - cam.origin) * cam.scale;
else
    pix = world2img(P, cam.pose, cam.intrinsics, ApplyDistortion=true);
end
end
