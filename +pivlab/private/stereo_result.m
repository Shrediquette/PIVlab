function res = stereo_result(cams, info, calibration, s)
%STEREO_RESULT API result struct of a stereo-PIV analysis from the 2D results of both cameras.
%   res = stereo_result(cams, info, calibration, s)
%   cams         1x2 cell, API results of camera 1 and 2 (pivlab.analyze / pivlab.filter on the rectified,
%                disparity-corrected images; same grid)
%   info         calib, disparity, images (1x2 cell, image sets of both cameras), roi, stereo_settings, board
%                (ChArUco board definition), boards (1x2 cell, board images or files)
%   calibration  res.calibration to use ([] = uncalibrated, px/frame)
%   s            settings (pivlab.defaults format)
% The result is the normal API result (res.u, res.v, typevector, ...) of U, V plus res.w (px data in res.px.w),
% computed with stereo.combine_cameras like in the GUI: res.px.u/v/w from the validated (or, before
% pivlab.filter, the raw) 2D results, res.px.u_raw/v_raw/w_raw from the raw 2D results.
% res.stereo: calib, disparity (without the full-size maps), cameras (the two 2D results), images, roi,
% settings, residual, residual_raw, sheet_z_mm, mm_per_px, x_mm, y_mm, board, boards.
raw = cell(1, 2);
validated = cell(1, 2);
for k = 1:2
    p = cams{k}.px;
    raw{k} = struct('x', p.x, 'y', p.y, 'u', p.u_raw, 'v', p.v_raw, 'typevector', cams{k}.typevector_raw, ...
        'correlation', cams{k}.correlation_map);
    validated{k} = struct('x', p.x, 'y', p.y, 'u', p.u, 'v', p.v, 'typevector', cams{k}.typevector, ...
        'correlation', cams{k}.correlation_map);
end
recon = info.stereo_settings.reconstruction;
Cr = stereo.combine_cameras(raw{1}, raw{2}, info.calib, info.disparity, recon);
Cv = Cr;
if cams{1}.filtered || cams{2}.filtered
    Cv = stereo.combine_cameras(validated{1}, validated{2}, info.calib, info.disparity, recon);
end
res = struct();
res.x = []; res.y = []; res.u = []; res.v = []; res.w = [];
res.typevector = Cv.typevector;
res.u_raw = []; res.v_raw = []; res.w_raw = [];
res.typevector_raw = Cr.typevector;
res.correlation_map = Cv.correlation;
res.uncertainty = [];
res.units = "px/frame";
if isempty(calibration)
    calibration = cams{1}.calibration;
end
res.calibration = calibration;
res.filtered = cams{1}.filtered || cams{2}.filtered;
res.smoothed = false;
res.derived = struct();
res.frameLabels = cams{1}.frameLabels;
res.isMean = false(size(cams{1}.isMean));
res.pairs = cams{1}.pairs;
res.px = struct('x', Cv.x, 'y', Cv.y, 'u', Cv.U, 'v', Cv.V, 'w', Cv.W, 'u_raw', Cr.U, 'v_raw', Cr.V, ...
    'w_raw', Cr.W, 'u2', [], 'v2', [], 'u_smoothed', [], 'v_smoothed', [], 'w_smoothed', [], 'uncertainty', []);
res.images = info.images{1}; % camera 1, rectified and disparity-corrected (display, image size)
res.settings = s;
disparity = info.disparity;
for name = {'u_full', 'v_full', 'xq', 'yq'}
    if isfield(disparity, name{1})
        disparity = rmfield(disparity, name{1}); % the full-size maps are large; stereo.full_disparity makes them
    end
end
res.stereo = struct('calib', info.calib, 'disparity', disparity, 'cameras', {cams}, 'images', {info.images}, ...
    'roi', info.roi, 'settings', info.stereo_settings, 'residual', Cv.residual, 'residual_raw', Cr.residual, ...
    'sheet_z_mm', Cv.sheet_z_mm, 'mm_per_px', Cv.mm_per_px, 'x_mm', Cv.x_mm, 'y_mm', Cv.y_mm, ...
    'board', info.board, 'boards', {info.boards});
res = refresh_units(res);
end
