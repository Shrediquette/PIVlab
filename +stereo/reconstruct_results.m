function [resultslist, stereo_vel] = reconstruct_results(raw, only_frames)
%RECONSTRUCT_RESULTS Three velocity components from the 2D results of both cameras (GUI data).
%   [resultslist, stereo_vel] = stereo.reconstruct_results(false)   from the validated 2D results (if validated)
%   [resultslist, stereo_vel] = stereo.reconstruct_results(true)    from the raw 2D results (rows 3/4/5), e.g.
%                                                                   for the velocity limits (stereo.limit_discard)
%   [...] = stereo.reconstruct_results(raw, only_frames)            only these image pairs (the others stay empty)
% The 2D results (gui.retr('stereo_result') of camera 1 and 2) go into stereo.reconstruct. The result list
% holds U, V (rows 1-9 like a validated 2D result: a vector is valid if it is valid in both cameras,
% interpolated if one camera interpolated it, masked if one camera masked it), so all PIVlab displays, derived
% parameters and exports of U, V work. W is row 16 (row 17: smoothed W, stereo.w_of_frame). stereo_vel holds
% the consistency residual and the light sheet position. Both are [] if there is nothing to reconstruct.
% Units: px per image pair of the common grid (square pixels; the spatial calibration applies as in 2D).
% stereo.update_result stores the validated result in the GUI.
if nargin < 2
    only_frames = [];
end
resultslist = [];
stereo_vel = [];
calib = gui.retr('stereo_calib');
R = cell(1, 2);
active = gui.retr('stereo_active_camera');
state = gui.retr('stereo_cam_state');
for k = 1:2
    if k == active
        R{k} = gui.retr('stereo_result');
    elseif isfield(state{k}, 'stereo_result')
        R{k} = state{k}.stereo_result;
    end
end
if isempty(calib) || isempty(R{1}) || isempty(R{2})
    return
end
n = min(size(R{1}, 2), size(R{2}, 2));
frames = [];
for i = 1:n
    if ~isempty(R{1}{1, i}) && ~isempty(R{2}{1, i}) && (isempty(only_frames) || any(only_frames == i))
        frames(end + 1) = i; %#ok<AGROW>
    end
end
if isempty(frames)
    return
end
x = R{1}{1, frames(1)};
y = R{1}{2, frames(1)};
sz = size(x);
cams = cell(1, 2);
for k = 1:2
    cams{k}.x = x;
    cams{k}.y = y;
    cams{k}.u = NaN([sz numel(frames)]);
    cams{k}.v = NaN([sz numel(frames)]);
    cams{k}.typevector = ones([sz numel(frames)]);
    cams{k}.correlation = NaN([sz numel(frames)]);
    for j = 1:numel(frames)
        rl = R{k}(:, frames(j));
        if ~isequal(size(rl{1}), sz)
            error('stereo:update_result', 'Both cameras must be analysed on the same grid (same region of interest and PIV settings).');
        end
        if ~raw && numel(rl) >= 8 && ~isempty(rl{7}) % validated
            cams{k}.u(:, :, j) = rl{7};
            cams{k}.v(:, :, j) = rl{8};
            cams{k}.typevector(:, :, j) = rl{9};
        else
            cams{k}.u(:, :, j) = rl{3};
            cams{k}.v(:, :, j) = rl{4};
            cams{k}.typevector(:, :, j) = rl{5};
        end
        if numel(rl) >= 12 && ~isempty(rl{12}) % correlation map (row 12, as in 2D; row 6 is empty)
            cams{k}.correlation(:, :, j) = rl{12};
        end
    end
end
C = stereo.combine_cameras(cams{1}, cams{2}, calib, gui.retr('stereo_disparity')); % shared with the API
resultslist = cell(16, max(frames));
residual = NaN([sz max(frames)], 'single');
for j = 1:numel(frames)
    i = frames(j);
    resultslist{1, i} = x;
    resultslist{2, i} = y;
    resultslist{3, i} = C.U(:, :, j);
    resultslist{4, i} = C.V(:, :, j);
    resultslist{5, i} = double(C.typevector(:, :, j) > 0);
    resultslist{12, i} = C.correlation(:, :, j); % the smaller correlation of both cameras
    resultslist{7, i} = C.U(:, :, j);
    resultslist{8, i} = C.V(:, :, j);
    resultslist{9, i} = C.typevector(:, :, j);
    resultslist{16, i} = C.W(:, :, j);
    residual(:, :, i) = single(C.residual(:, :, j));
end
stereo_vel.residual = residual;
stereo_vel.sheet_z_mm = C.sheet_z_mm;
stereo_vel.mm_per_px = C.mm_per_px;
stereo_vel.x_mm = C.x_mm;
stereo_vel.y_mm = C.y_mm;
end
