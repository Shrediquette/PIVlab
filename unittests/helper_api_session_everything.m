function [res, imgs, f, roi, lim] = helper_api_session_everything(folder)
%HELPER_API_SESSION_EVERYTHING Session of the command-line API that uses "everything": fisheye images
%   with camera undistortion, ROI, masks per pair, background, high-pass, 3 passes, calibration with
%   origin and flipped axes, velocity limits and spatial smoothing. Saved as folder/everything.mat.
%   res   the result that was saved     imgs  its images
%   f     the session file              roi, lim  the ROI and the velocity limits used
files = helper_files('distortion', 3);
raw = pivlab.readImages(files, "pairwise");
cp = helper_camera_model(raw.imageSize);
imgs = pivlab.preprocess(raw, Camera=cp, CameraView="same", Verbose=false);
sz = imgs.imageSize;
m1 = false(sz);
m1(300:400, 300:450) = true;
roi = [60 50 sz(2)-150 sz(1)-120];
imgs = pivlab.preprocess(imgs, Camera=cp, CameraView="same", Roi=roi, Mask={m1, {}, {'ROI_object_rectangle', [200 200 100 80]}}, ...
    Background="mean", Highpass=true, Verbose=false);
res = pivlab.analyze(imgs, Passes=3, PassSizes=[32 24 24], Verbose=false);
res = pivlab.toMetric(res, DeltaT=0.0005, PxPerMeter=8000, Origin=[100 120], XAxis="left", YAxis="up", Verbose=false);
lim = [-0.6 0.6 -0.6 0.6];
res = pivlab.filter(res, VelocityLimits=lim, StdevThreshold=6, Verbose=false);
[res, ~] = pivlab.derive(res, "vorticity", Smoothing="spatial", SmoothingStrength=1);
f = fullfile(folder, 'everything.mat');
pivlab.saveSession(res, f, Verbose=false);
end
