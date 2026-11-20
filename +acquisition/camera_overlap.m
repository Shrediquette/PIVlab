function ov = camera_overlap(markers)
%CAMERA_OVERLAP Overlap of the views of two cameras, from one ChArUco board that both cameras see.
%   ov = acquisition.camera_overlap(markers)
%   markers{k}.ids    marker IDs of camera k (readArucoMarker)
%   markers{k}.locs   4x2xN marker corners in the coordinates of camera k's image (also when the board is seen
%                     from behind: corners mirrored back, see PIVlab_capture_charuco_detector)
%   markers{k}.size   [height width] of camera k's image
%   The corners of the markers that both cameras see (same ID) give a projective transform from camera 1 to
%   camera 2 (RANSAC, wrongly decoded markers are outliers). It is valid in the plane of the board (the light
%   sheet when the board is placed there); lens distortion is not included (straight frame edges).
%   ov.ok          true when the transform could be fitted (at least 2 common markers, 8 inlier corners)
%   ov.n_common    number of markers seen by both cameras
%   ov.tform       projtform2d, camera 1 -> camera 2 image coordinates
%   ov.region{k}   polyshape in camera k's image: the part of camera k's view that the other camera sees too
%   ov.fraction(k) area of ov.region{k} / area of camera k's image
%   Used for the live image of stereo acquisition (acquisition.draw_camera_overlap: aligning the cameras). Two
%   cameras for a larger field of view (dev_notes/two_camera_fov_plan.md) can use it in the same way.
ov.ok = false;
ov.n_common = 0;
ov.tform = [];
ov.region = {polyshape(), polyshape()};
ov.fraction = [0 0];
if numel(markers) < 2 || isempty(markers{1}) || isempty(markers{2})
	return
end
[ids1, locs1] = unique_markers(markers{1});
[ids2, locs2] = unique_markers(markers{2});
[~, i1, i2] = intersect(ids1, ids2);
ov.n_common = numel(i1);
if ov.n_common < 2
	return
end
% corresponding corners: corner c of marker i in camera 1 = corner c of the same marker in camera 2
p1 = reshape(permute(locs1(:, :, i1), [1 3 2]), [], 2);
p2 = reshape(permute(locs2(:, :, i2), [1 3 2]), [], 2);
% inlier distance: a wrongly decoded marker is off by at least one checker
side = sqrt(sum((locs2(2, :, i2) - locs2(1, :, i2)).^2, 2));
max_distance = max(2, 0.1 * median(side(:)));
try
	[tform, inliers] = estgeotform2d(p1, p2, 'projective', 'MaxDistance', max_distance, 'Confidence', 99.9, 'MaxNumTrials', 1000);
catch
	return % too few or degenerate points
end
if nnz(inliers) < 8
	return
end
ov.ok = true;
ov.tform = tform;
A = tform.A;
B = inv(A); % camera 2 -> camera 1
ov.region{2} = mapped_frame(A, markers{1}.size, markers{2}.size);
ov.region{1} = mapped_frame(B, markers{2}.size, markers{1}.size);
for k = 1:2
	ov.fraction(k) = area(ov.region{k}) / prod(markers{k}.size);
end

function [ids, locs] = unique_markers(m)
%markers whose ID was found more than once (one of them wrongly decoded) are not used
ids = m.ids(:);
locs = m.locs;
[u, ~, idx] = unique(ids);
counts = accumarray(idx, 1);
keep = ismember(ids, u(counts == 1));
ids = ids(keep);
locs = locs(:, :, keep);

function region = mapped_frame(A, size_from, size_to)
%frame of one camera image mapped with the projective matrix A ([x' y' w]' = A*[x y 1]') into the other
%camera's image, clipped to that image. Points that map behind the camera (w <= 0) are left out.
h = size_from(1);
w = size_from(2);
n = 50; % points per edge (the edges are straight, but they may cross the horizon)
t = (0:n-1)' / n; % without the end point: it is the start of the next edge
x = [0.5 + t*w; (w+0.5)*ones(n,1); w+0.5 - t*w; 0.5*ones(n,1)];
y = [0.5*ones(n,1); 0.5 + t*h; (h+0.5)*ones(n,1); h+0.5 - t*h];
q = A * [x'; y'; ones(1, numel(x))];
front = q(3, :) > 0;
if all(front)
	front = false(1, numel(x)); % the whole frame in front: the 4 corners are enough (straight edges)
	front(1:n:end) = true;
end
region = polyshape();
if nnz(front) < 3
	return
end
xm = q(1, front) ./ q(3, front);
ym = q(2, front) ./ q(3, front);
frame_to = polyshape([0.5 size_to(2)+0.5 size_to(2)+0.5 0.5], [0.5 0.5 size_to(1)+0.5 size_to(1)+0.5]);
old_warning = warning;
warning('off', 'MATLAB:polyshape:repairedBoundary');
warning('off', 'MATLAB:polyshape:repairedBySimplify');
mapped = polyshape(xm, ym);
warning(old_warning);
region = intersect(mapped, frame_to);
