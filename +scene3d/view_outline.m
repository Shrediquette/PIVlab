function B = view_outline(intrinsics, extrinsics)
%VIEW_OUTLINE Where the border of the image of a camera meets the board plane (z = 0).
%   B = scene3d.view_outline(intrinsics, extrinsics)
% intrinsics: cameraIntrinsics, extrinsics: rigidtform3d, board -> camera.
% B: board coordinates (N x 3) of the border, closed (simulate.footprint, with the lens distortion);
% [] if most of the border does not hit the board plane in front of the camera.
xy = simulate.footprint(simulate.camera(Intrinsics=intrinsics, Pose=extrinsics));
if size(xy, 1) < 0.75 * 80 % simulate.footprint: 4 x 20 points of the border
    B = [];
    return
end
B = [xy, zeros(size(xy, 1), 1)];
B(end + 1, :) = B(1, :);
end
