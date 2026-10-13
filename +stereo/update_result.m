function update_result
%UPDATE_RESULT Three velocity components from the 2D results of both cameras (GUI).
%   stereo.update_result
% The 2D results (gui.retr('stereo_result') of camera 1 and 2, validated if the validation was applied)
% go into stereo.reconstruct. The result list of the GUI then holds U, V (rows 1-9 like a validated 2D
% result: a vector is valid if it is valid in both cameras, interpolated if one camera interpolated it,
% masked if one camera masked it), so all PIVlab displays, derived parameters and exports of U, V work.
% W is row 16 of the result list (row 17: smoothed W, stereo.w_of_frame). The consistency residual and
% the light sheet position are kept in gui.retr('stereo_vel').
% Units: px per image pair of the common grid (square pixels; the spatial calibration applies as in 2D).
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
gui.put('derived', []);
if isempty(calib) || isempty(R{1}) || isempty(R{2})
    gui.put('resultslist', []);
    gui.put('stereo_vel', []);
    return
end
n = min(size(R{1}, 2), size(R{2}, 2));
frames = [];
for i = 1:n
    if ~isempty(R{1}{1, i}) && ~isempty(R{2}{1, i})
        frames(end + 1) = i; %#ok<AGROW>
    end
end
if isempty(frames)
    gui.put('resultslist', []);
    gui.put('stereo_vel', []);
    return
end
x = R{1}{1, frames(1)};
y = R{1}{2, frames(1)};
sz = size(x);
res = cell(1, 2);
tv = cell(1, 2);
cm = cell(1, 2);
for k = 1:2
    res{k}.px.x = x;
    res{k}.px.y = y;
    res{k}.px.u = NaN([sz numel(frames)]);
    res{k}.px.v = NaN([sz numel(frames)]);
    res{k}.px.u_smoothed = [];
    res{k}.px.v_smoothed = [];
    tv{k} = ones([sz numel(frames)]);
    cm{k} = NaN([sz numel(frames)]);
    for j = 1:numel(frames)
        rl = R{k}(:, frames(j));
        if ~isequal(size(rl{1}), sz)
            error('stereo:update_result', 'Both cameras must be analysed on the same grid (same region of interest and PIV settings).');
        end
        if numel(rl) >= 8 && ~isempty(rl{7}) % validated
            res{k}.px.u(:, :, j) = rl{7};
            res{k}.px.v(:, :, j) = rl{8};
            tv{k}(:, :, j) = rl{9};
        else
            res{k}.px.u(:, :, j) = rl{3};
            res{k}.px.v(:, :, j) = rl{4};
            tv{k}(:, :, j) = rl{5};
        end
        if numel(rl) >= 6 && ~isempty(rl{6})
            cm{k}(:, :, j) = rl{6};
        end
    end
end
vel = stereo.reconstruct(res{1}, res{2}, calib, stereo.full_disparity(calib, gui.retr('stereo_disparity')));
resultslist = cell(16, max(frames));
for j = 1:numel(frames)
    i = frames(j);
    t1 = tv{1}(:, :, j);
    t2 = tv{2}(:, :, j);
    typevector = ones(sz);
    typevector(t1 == 2 | t2 == 2) = 2;   % interpolated in one of the cameras
    typevector(t1 == 0 | t2 == 0) = 0;   % masked in one of the cameras
    U = vel.U(:, :, j);
    V = vel.V(:, :, j);
    U(typevector == 0) = NaN;
    V(typevector == 0) = NaN;
    resultslist{1, i} = x;
    resultslist{2, i} = y;
    resultslist{3, i} = U;
    resultslist{4, i} = V;
    resultslist{5, i} = double(typevector > 0);
    resultslist{6, i} = min(cm{1}(:, :, j), cm{2}(:, :, j));
    resultslist{7, i} = U;
    resultslist{8, i} = V;
    resultslist{9, i} = typevector;
    W = vel.W(:, :, j);
    W(typevector == 0) = NaN;
    resultslist{16, i} = W;
end
gui.put('resultslist', resultslist);
residual = NaN([sz max(frames)], 'single');
for j = 1:numel(frames)
    i = frames(j);
    r = single(vel.residual(:, :, j));
    r(resultslist{9, i} == 0) = NaN;
    residual(:, :, i) = r;
end
stereo_vel.residual = residual;
stereo_vel.sheet_z_mm = vel.sheet_z_mm;
stereo_vel.mm_per_px = vel.mm_per_px;
stereo_vel.x_mm = vel.x_mm;
stereo_vel.y_mm = vel.y_mm;
gui.put('stereo_vel', stereo_vel);
end
