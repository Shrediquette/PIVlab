function res = helper_truth_result(F, folder, n_frames, with_w)
%HELPER_TRUTH_RESULT A pivlab result struct (pixel units) that holds the analytic flow F
%   (helper_truth_flow) instead of a PIV result: the exact level of the truth-based tests.
%   res = helper_truth_result(F, folder, n_frames, with_w)
%   folder    empty temporary folder for the (noise) images of the template analysis
%   n_frames  number of frames (all hold the same field; change them with helper_truth_set)
%   with_w    true: also the stereo component w (res.px.w, positive away from the camera)
%
%   A quick pivlab.analyze of noise images gives a result struct with all fields; then the vector
%   field is replaced by F. The vector grid is 16 px (32 px windows), typevector 1,
%   correlation coefficient and uncertainty are known maps (see helper_truth_set).
if nargin < 4
    with_w = false;
end
files = strings(1, 2 * n_frames);
rng(7);
for k = 1:2 * n_frames
    img = uint8(255 * rand(F.size));
    files(k) = fullfile(folder, sprintf('truth_%03d.tif', k));
    imwrite(img, files(k));
end
imgs = pivlab.readImages(files, "pairwise");
res = pivlab.analyze(imgs, InterrogationArea=32, Step=16, Passes=1, Verbose=false);
x = double(res.px.x);
y = double(res.px.y);
T = helper_truth_field(F, x, y);
u = repmat(T.u, 1, 1, n_frames);
v = repmat(T.v, 1, 1, n_frames);
w = [];
if with_w
    w = repmat(T.w, 1, 1, n_frames);
end
res = helper_truth_set(res, u, v, w);
end
