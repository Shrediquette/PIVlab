function tests = test_gui_truth_extraction
%TEST_GUI_TRUTH_EXTRACTION PIVlab window: poly-line and area extraction ("Extractions" menu) against the
%   analytic truth, for all axis settings and calibrations of helper_truth_cases. An analytic field (no
%   PIV error) replaces the result of a quick analysis of noise images (as in test_gui_truth, which
%   checks a straight line in a uniform flow, the circle, the circle series, a rectangle and a circle
%   area). Checked here:
%   - every quantity of the poly-line list along a line with bends in a linear flow (values at the
%     right positions, coordinates and distance of every point, tangent / normal velocity per segment)
%   - vector direction across the +-180 degree branch cut (line and area: circular mean)
%   - a line through a masked area: NaN inside the mask, the truth outside
%   - every quantity of the area list in a rectangle, a polygon area, circle areas of small and large
%     radius, the circle series area (area and circulation of every circle)
%   - an area that is partly masked: area of the drawn shape, mean and integral without the mask
%   - export of the line and of the area for all frames (text files)
%   File dialogs are replaced by unittests/parity/mocks. No stereo (w component).
%   Run with: run_pivlab_tests('test_gui_truth_extraction')
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
helper_setup_once(testCase);
addpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'), '-begin');   % uiputfile
sz = [320 320];
files = cell(4, 1);   % two image pairs (frames 1 and 2)
rng(7);
for k = 1:4
    files{k} = fullfile(testCase.TestData.Dir, sprintf('noise_%d.tif', k));
    imwrite(uint8(255 * rand(sz)), files{k});
end
helper_close_pivlab();
helper_start_pivlab();
h = gui.gethand;
set(h.pass1_size, 'String', '32');   % 16 px vector grid, one pass
piv.intarea_Callback(h.pass1_size, [], []);
set(h.pass1_step, 'String', '16');
piv.step_Callback(h.pass1_step, [], []);
set(h.pass2_enable, 'Value', 0);
piv.pass2_checkbox_Callback(h.pass2_enable, [], []);
helper_gui_load_images(files, 1);
helper_gui_analyze();
testCase.TestData.size = sz;
end

function teardownOnce(testCase)
helper_close_pivlab();
rmpath(fullfile(testCase.TestData.Root, 'unittests', 'parity', 'mocks'));
setappdata(0, 'parity_mock_file', []);
helper_teardown_once(testCase);
end

function setup(testCase)
helper_truth_log(testCase, 'start');
gui.put('masks_in_frame', {});
end

function teardown(testCase)
gui.put('masks_in_frame', {});
helper_truth_log(testCase, 'end');
end

%% ------------------------------------------------------------------ poly-line

function test_polyline_all_quantities(testCase)
% linear flow: u, v, correlation and uncertainty are linear in x and y, so their interpolation is
% exact: the value of every point of the line must be the truth at the position of that point.
% Gradients are constant; magnitude and direction are not linear (bilinear interpolation between the
% vectors: about 1e-3 relative).
F = helper_truth_flow('linear', testCase.TestData.size);
[x, y] = put_field(F);
P = [70 250; 120 80; 210 170; 260 70];    % three segments with bends (px, y down)
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    label = c.name;
    set_calibration(c, F.size);
    set_polyline(P);
    for item = 1:13
        [val, distance, cx, cy] = extract_line(item);
        s = distance / c.calxy;                       % distance along the line in px
        [px, py, seg] = polyline_points(P, s);
        E = helper_truth_expected(helper_truth_field(F, px, py), c, px, py, F.size);
        if item == 1
            helper_verify_near(testCase, distance(end), sum(segment_lengths(P)) * c.calxy, 'RelTol', 1e-9, ...
                [label ': length of the line']);
            helper_truth_verify(testCase, cx(:), E.x, 1e-6, [label ': x of the points']);
            helper_truth_verify(testCase, cy(:), E.y, 1e-6, [label ': y of the points']);
        end
        name = sprintf('%s: item %d', label, item);
        g = max(abs([E.vorticity(1) E.divergence(1) E.strain(1) E.shear(1)]));
        switch item
            case 1
                helper_truth_verify(testCase, val, E.vorticity, 1e-5, [name ' vorticity'], [], g);
            case 2
                helper_truth_verify(testCase, val, E.magnitude, 2e-3, [name ' magnitude']);
            case 3
                helper_truth_verify(testCase, val, E.u, 1e-4, [name ' u'], [], max(E.magnitude));
            case 4
                helper_truth_verify(testCase, val, E.v, 1e-4, [name ' v'], [], max(E.magnitude));
            case 5
                helper_truth_verify(testCase, val, E.divergence, 1e-5, [name ' divergence'], [], g);
            case 6
                helper_truth_verify(testCase, val, E.qcriterion, 2e-5, [name ' Q criterion'], [], g^2);
            case 7
                helper_truth_verify(testCase, val, E.shear, 1e-5, [name ' shear rate'], [], g);
            case 8
                helper_truth_verify(testCase, val, E.strain, 1e-5, [name ' strain rate'], [], g);
            case 9
                verify_angle(testCase, val, E.direction, 0.1, [name ' direction']);
            case 10
                helper_truth_verify(testCase, val, correlation_truth(px, x), 1e-4, [name ' correlation']);
            case 11
                helper_truth_verify(testCase, val, uncertainty_truth(py, y) * E.fv, 1e-4, [name ' uncertainty']);
            case {12, 13}
                % unit vector of each segment in the user's axes; normal = tangent turned by +90 degrees
                d = diff(P);
                t = [c.sx * d(:, 1), c.sy * (-d(:, 2))] ./ segment_lengths(P);
                if item == 13
                    t = [-t(:, 2) t(:, 1)];
                end
                expected = E.u .* t(seg, 1) + E.v .* t(seg, 2);
                % PIVlab takes the direction from a point and the point before it: at a bend this
                % direction cuts the corner, so the points next to the bends are left out
                ok = away_from_bends(P, s, 1.5 * (s(2) - s(1)));
                helper_truth_verify(testCase, val, expected, 1e-4, [name ' tangent / normal velocity'], ok, max(E.magnitude));
        end
    end
end
end

function test_polyline_direction_across_branch_cut(testCase)
% a flow to the left on the screen (direction about 180 degrees where x points right) that turns
% slowly from below to above: along a horizontal line the direction goes through +-180 degrees.
% It must follow the truth (no averaged angles around 0 degrees at the branch cut).
F = branch_cut_flow(testCase.TestData.size);
put_field(F);
P = [60 160.5; 260 160.5];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    set_polyline(P);
    [val, distance] = extract_line(9);
    s = distance / c.calxy;
    [px, py] = polyline_points(P, s);
    E = helper_truth_expected(helper_truth_field(F, px, py), c, px, py, F.size);
    verify_angle(testCase, val, E.direction, 0.1, [c.name ': direction along the line']);
end
end

function test_polyline_through_mask(testCase)
% a horizontal line through a masked rectangle: the masked vectors are NaN (typevector 0, as after
% the analysis). Inside the mask the line has no data; at 2.5 vectors (40 px) or more from the mask
% the values are the truth (closer, the derived quantities use interpolated vectors of the mask).
F = helper_truth_flow('linear', testCase.TestData.size);
[x, y] = put_field(F);
mask_rect = [130 100 60 120];     % x, y, width, height (px)
put_mask(mask_rect, x, y);
P = [40 160.5; 280 160.5];
margin = 40;
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    set_polyline(P);
    for item = [1 3 9 10 12]
        [val, distance] = extract_line(item);
        s = distance / c.calxy;
        [px, py, seg] = polyline_points(P, s);
        E = helper_truth_expected(helper_truth_field(F, px, py), c, px, py, F.size);
        inside = px >= mask_rect(1) & px <= mask_rect(1) + mask_rect(3);
        far = px < mask_rect(1) - margin | px > mask_rect(1) + mask_rect(3) + margin;
        name = sprintf('%s: item %d', c.name, item);
        testCase.verifyTrue(all(isnan(val(inside))), sprintf('%s: %d of %d points inside the mask have a value', ...
            name, nnz(~isnan(val(inside))), nnz(inside)));
        testCase.verifyFalse(any(isnan(val(far))), [name ': NaN far from the mask']);
        switch item
            case 1
                g = max(abs([E.vorticity(1) E.divergence(1) E.strain(1)]));
                helper_truth_verify(testCase, val, E.vorticity, 1e-5, [name ' vorticity far from the mask'], far, g);
            case 3
                helper_truth_verify(testCase, val, E.u, 1e-4, [name ' u far from the mask'], far, max(E.magnitude));
            case 9
                verify_angle(testCase, val(far), E.direction(far), 0.1, [name ' direction far from the mask']);
            case 10
                helper_truth_verify(testCase, val, correlation_truth(px, x), 1e-4, [name ' correlation far from the mask'], far);
            case 12
                t = [c.sx 0];       % the line points to the right on the screen
                expected = E.u * t(1) + E.v * t(2) + 0 * seg;
                helper_truth_verify(testCase, val, expected, 1e-4, [name ' tangent velocity far from the mask'], far, max(E.magnitude));
        end
    end
end
end

%% ------------------------------------------------------------------ areas

function test_rectangle_all_quantities(testCase)
% linear flow: the mean of a linear quantity over the pixels of the rectangle is the mean of the
% truth at these pixels; gradients are constant; integral = mean * area
F = helper_truth_flow('linear', testCase.TestData.size);
[x, y] = put_field(F);
rect = [100 90 120 100];      % x, y, width, height (px)
BW = poly2mask(rect(1) + [0 rect(3) rect(3) 0], rect(2) + [0 0 rect(4) rect(4)], F.size(1), F.size(2));
[py, px] = find(BW);
C = helper_truth_cases();
for k = 1:numel(C)
    c = C(k);
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_rectangle_area');
    gui.put('xposition', rect([1 3]));
    gui.put('yposition', rect([2 4]));
    E = helper_truth_expected(helper_truth_field(F, px, py), c, px, py, F.size);
    g = max(abs([E.vorticity(1) E.divergence(1) E.strain(1) E.shear(1)]));
    fields = {'vorticity', 1e-5, g; 'magnitude', 2e-3, []; 'u', 1e-4, max(E.magnitude); 'v', 1e-4, max(E.magnitude); ...
        'divergence', 1e-5, g; 'qcriterion', 2e-5, g^2; 'shear', 1e-5, g; 'strain', 1e-5, g};
    for item = 1:11
        data = extract_area(item);
        name = sprintf('%s: area item %d', c.name, item);
        helper_verify_near(testCase, data{1}, rect(3) * rect(4) * c.calxy^2, 'RelTol', 1e-9, [name ': area']);
        if item <= 8
            truth = mean(E.(fields{item, 1}));
            scale = fields{item, 3};
            if isempty(scale)
                scale = abs(truth);
            end
            testCase.verifyLessThanOrEqual(abs(data{2} - truth), fields{item, 2} * scale + 1e-12, ...
                sprintf('%s: mean %s %.8g, truth %.8g', name, fields{item, 1}, data{2}, truth));
        elseif item == 9
            truth = atan2d(mean(sind(E.direction)), mean(cosd(E.direction)));
            verify_angle(testCase, data{2}, truth, 0.1, [name ': circular mean of the direction']);
        elseif item == 10
            truth = mean(correlation_truth(px, x));
            helper_verify_near(testCase, data{2}, truth, 'RelTol', 1e-4, [name ': mean correlation']);
        else
            truth = mean(uncertainty_truth(py, y)) * E.fv;
            helper_verify_near(testCase, data{2}, truth, 'RelTol', 1e-4, [name ': mean uncertainty']);
        end
        if item ~= 9    % the integral of an angle has no meaning (and PIVlab takes the arithmetic mean for it)
            helper_verify_near(testCase, data{3}, data{2} * data{1}, 'RelTol', 1e-9, [name ': integral = mean * area']);
        end
    end
end
end

function test_area_direction_across_branch_cut(testCase)
% directions of +179 and -179 degrees point the same way: the circular mean is 180 degrees (the
% arithmetic mean would be about 0)
F = branch_cut_flow(testCase.TestData.size);
put_field(F);
rect = [110 110 100 100];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_rectangle_area');
    gui.put('xposition', rect([1 3]));
    gui.put('yposition', rect([2 4]));
    data = extract_area(9);
    centre = rect(1:2) + rect(3:4) / 2;
    E = helper_truth_expected(helper_truth_field(F, centre(1), centre(2)), c, centre(1), centre(2), F.size);
    verify_angle(testCase, data{2}, E.direction, 0.5, [c.name ': circular mean of the direction']);
end
end

function test_polygon_area(testCase)
% triangle: area (shoelace formula, the pixels give a small discretization error) and the mean of u
% in a linear flow (mean of the truth at the pixels of the triangle)
F = helper_truth_flow('linear', testCase.TestData.size);
put_field(F);
P = [80 240; 240 220; 150 70];
area_px = 0.5 * abs((P(2, 1) - P(1, 1)) * (P(3, 2) - P(1, 2)) - (P(3, 1) - P(1, 1)) * (P(2, 2) - P(1, 2)));
BW = poly2mask(P(:, 1), P(:, 2), F.size(1), F.size(2));
[py, px] = find(BW);
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_poly_area');
    gui.put('xposition', P(:, 1));
    gui.put('yposition', P(:, 2));
    data = extract_area(3);
    E = helper_truth_expected(helper_truth_field(F, px, py), c, px, py, F.size);
    helper_verify_near(testCase, data{1}, area_px * c.calxy^2, 'RelTol', 0.01, [c.name ': triangle area']);
    testCase.verifyLessThanOrEqual(abs(data{2} - mean(E.u)), 1e-4 * max(E.magnitude), ...
        sprintf('%s: mean u in the triangle %.8g, truth %.8g', c.name, data{2}, mean(E.u)));
    helper_verify_near(testCase, data{3}, data{2} * data{1}, 'RelTol', 1e-9, [c.name ': integral = mean * area']);
end
end

function test_circle_area_small_and_large(testCase)
% the area of the drawn circle (pi r^2) for small and large radii, within 2 % (pixel discretization)
F = helper_truth_flow('uniform', testCase.TestData.size);
put_field(F);
centre = [F.xc F.yc];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    for R = [16 40 80]
        gui.put('extract_type', 'extract_circle_area');
        gui.put('xposition', centre);
        gui.put('yposition', R);
        data = extract_area(3);
        helper_verify_near(testCase, data{1}, pi * R^2 * c.calxy^2, 'RelTol', 0.02, ...
            sprintf('%s: area of a circle with r = %d px (%.5g, pi r^2 = %.5g)', c.name, R, data{1}, pi * R^2 * c.calxy^2));
    end
end
end

function test_circle_series_area(testCase)
% circle series around the Oseen vortex: area of every circle = pi r^2, area integral of the
% vorticity = circulation gamma(r) (sign along z = x cross y)
F = helper_truth_flow('oseen', testCase.TestData.size);
x = put_field(F);
R = 80;
step = ceil(double(x(1, 2) - x(1, 1)));
radii = [linspace(step, R - step, round((R - step) / step)) R];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_circle_series_area');
    gui.put('xposition', [F.xc F.yc]);
    gui.put('yposition', R);
    data = extract_area(1);
    testCase.verifyEqual(size(data, 1), numel(radii), [c.name ': number of circles']);
    if size(data, 1) ~= numel(radii)
        continue
    end
    area = cell2mat(data(:, 2))';
    integral = cell2mat(data(:, 4))';
    helper_verify_near(testCase, area, pi * radii.^2 * c.calxy^2, 'RelTol', 0.02, [c.name ': area of the circles']);
    truth = c.sx * c.sy * F.gamma * (1 - exp(-radii.^2 / F.rc^2)) * c.calxy^2 / c.t;
    testCase.verifyLessThan(max(abs(integral - truth)), 0.06 * max(abs(truth)), ...
        sprintf('%s: circulation of the circles (largest %.4g, truth %.4g)', c.name, integral(end), truth(end)));
end
end

function test_partly_masked_area(testCase)
% rectangle that is partly masked: the area is the drawn area, the mean and the integral are taken
% without the masked pixels (uniform flow: integral = u * unmasked area)
F = helper_truth_flow('uniform', testCase.TestData.size);
[x, y, T] = put_field(F);
rect = [100 90 120 100];
mask_rect = [180 60 80 80];     % overlap: x 180..220, y 90..140 = 40 x 50 px
put_mask(mask_rect, x, y);
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    E = helper_truth_expected(T, c, x, y, F.size);
    gui.put('extract_type', 'extract_rectangle_area');
    gui.put('xposition', rect([1 3]));
    gui.put('yposition', rect([2 4]));
    data = extract_area(3);
    helper_verify_near(testCase, data{1}, 120 * 100 * c.calxy^2, 'RelTol', 1e-9, [c.name ': area with the masked part']);
    helper_verify_near(testCase, data{2}, E.u(1), 'RelTol', 1e-6, [c.name ': mean u without the mask']);
    helper_verify_near(testCase, data{3}, E.u(1) * (120 * 100 - 40 * 50) * c.calxy^2, 'RelTol', 1e-3, ...
        [c.name ': integral of u without the mask']);
end
end

%% ------------------------------------------------------------------ export

function test_export_line_all_frames(testCase)
% "Export data" of a poly-line for all frames, text file per frame: distance, x, y, value
F = helper_truth_flow('linear', testCase.TestData.size);
offsets = [0 0; 0.5 -0.3];
put_field(F, offsets);
h = gui.gethand;
P = [70 250; 200 90; 260 150];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    set_polyline(P);
    set(h.extraction_choice, 'Value', 3);      % u
    set(h.extractLineAll, 'Value', 1);
    set(h.extractionLine_fileformat, 'Value', 2);   % text file
    folder = fullfile(testCase.TestData.Dir, sprintf('line_%s_%d_%d', c.kind, c.xdir, c.ydir));
    mkdir(folder);
    setappdata(0, 'parity_mock_file', {folder, 'line.txt'});
    extract.save_data_Callback([], [], []);
    setappdata(0, 'parity_mock_file', []);
    set(h.extractLineAll, 'Value', 0);
    for f = 1:2
        file = fullfile(folder, sprintf('line_%d.txt', f));
        testCase.verifyTrue(isfile(file), sprintf('%s: file of frame %d', c.name, f));
        if ~isfile(file)
            continue
        end
        A = readmatrix(file, 'NumHeaderLines', 1);
        s = A(:, 1) / c.calxy;
        [px, py] = polyline_points(P, s);
        T = helper_truth_field(F, px, py);
        T.U = T.U + offsets(f, 1);     % offsets: px per frame, v downward
        T.V = T.V - offsets(f, 2);
        E = helper_truth_expected(T, c, px, py, F.size);
        name = sprintf('%s, frame %d', c.name, f);
        helper_verify_near(testCase, A(end, 1), sum(segment_lengths(P)) * c.calxy, 'RelTol', 1e-6, [name ': length']);
        helper_truth_verify(testCase, A(:, 2), E.x, 1e-6, [name ': x in the file']);
        helper_truth_verify(testCase, A(:, 3), E.y, 1e-6, [name ': y in the file']);
        helper_truth_verify(testCase, A(:, 4), E.u, 1e-4, [name ': u in the file'], [], max(E.magnitude));
    end
end
end

function test_export_area_all_frames(testCase)
% "Export data" of an area for all frames: one text file, one row per frame (area, mean, integral)
F = helper_truth_flow('uniform', testCase.TestData.size);
offsets = [0 0; 0.5 -0.3];
[x, y, T] = put_field(F, offsets);
h = gui.gethand;
rect = [100 90 120 100];
for c = helper_truth_cases('short')
    set_calibration(c, F.size);
    gui.put('extract_type', 'extract_rectangle_area');
    gui.put('xposition', rect([1 3]));
    gui.put('yposition', rect([2 4]));
    set(h.extraction_choice_area, 'Value', 3);    % u
    set(h.extractAreaAll, 'Value', 1);
    set(h.extractionArea_fileformat, 'Value', 2);
    folder = fullfile(testCase.TestData.Dir, sprintf('area_%s_%d_%d', c.kind, c.xdir, c.ydir));
    mkdir(folder);
    setappdata(0, 'parity_mock_file', {folder, 'area.txt'});
    extract.save_data_area_Callback([], [], []);
    setappdata(0, 'parity_mock_file', []);
    set(h.extractAreaAll, 'Value', 0);
    file = fullfile(folder, 'area.txt');
    testCase.verifyTrue(isfile(file), [c.name ': file']);
    if ~isfile(file)
        continue
    end
    A = readmatrix(file, 'NumHeaderLines', 1);
    testCase.verifyEqual(size(A, 1), 2, [c.name ': one row per frame']);
    for f = 1:min(2, size(A, 1))
        Tf = T;
        Tf.U = T.U + offsets(f, 1);
        Tf.V = T.V - offsets(f, 2);
        E = helper_truth_expected(Tf, c, x, y, F.size);
        name = sprintf('%s, frame %d', c.name, f);
        helper_verify_near(testCase, A(f, 1), rect(3) * rect(4) * c.calxy^2, 'RelTol', 1e-6, [name ': area']);
        helper_verify_near(testCase, A(f, 2), E.u(1), 'RelTol', 1e-6, [name ': mean u']);
        helper_verify_near(testCase, A(f, 3), E.u(1) * A(f, 1), 'RelTol', 1e-6, [name ': integral of u']);
    end
end
end

%% ------------------------------------------------------------------ local functions

function F = branch_cut_flow(sz)
% U = -1 - 0.002 Y, V = 0.002 X (px per frame, screen axes): flow to the left that turns from
% downward (left part) to upward (right part)
F = helper_truth_flow('linear', sz);
F.u0 = -1;
F.v0 = 0;
F.omega = 0.002;
F.a = 0;
F.s = 0;
end

function [x, y, T] = put_field(F, offsets)
% replace the PIV results of frames 1 and 2 by the analytic field (px per frame, v downward).
% offsets [du1 dv1; du2 dv2] (px per frame, v downward) are added to frame 1 and 2 (default 0).
if nargin < 2
    offsets = zeros(2, 2);
end
rl = gui.retr('resultslist');
rl = rl(:, 1:2);
x = double(rl{1, 1});
y = double(rl{2, 1});
T = helper_truth_field(F, x, y);
for f = 1:2
    rl{1, f} = rl{1, 1};
    rl{2, f} = rl{2, 1};
    rl{3, f} = T.u + offsets(f, 1);
    rl{4, f} = T.v + offsets(f, 2);
    rl{5, f} = ones(size(x));
    for r = [6 7 8 9 10 11 13 14]
        rl{r, f} = [];
    end
    rl{12, f} = correlation_truth(x, x);
    rl{15, f} = uncertainty_truth(y, y);
end
gui.put('resultslist', rl);
for name = {'filepath', 'filename', 'framenum', 'framepart'}
    value = gui.retr(name{1});
    if size(value, 1) > 4
        gui.put(name{1}, value(1:4, :));
    end
end
gui.put('ismean', []);
gui.sliderrange(1);
gui.put('derived', []);
gui.put('subtr_u', 0);
gui.put('subtr_v', 0);
gui.put('masks_in_frame', {});
end

function put_mask(rect, x, y)
% mask rectangle [x y width height] in frame 1 and 2; the vectors inside are NaN with typevector 0,
% as after an analysis with this mask
gui.put('masks_in_frame', {{'ROI_object_rectangle', rect}, {'ROI_object_rectangle', rect}});
inside = x >= rect(1) & x <= rect(1) + rect(3) & y >= rect(2) & y <= rect(2) + rect(4);
rl = gui.retr('resultslist');
for f = 1:2
    rl{3, f}(inside) = NaN;
    rl{4, f}(inside) = NaN;
    rl{5, f}(inside) = 0;
end
gui.put('resultslist', rl);
gui.put('derived', []);
end

function m = correlation_truth(xq, x)
% correlation coefficient of the field: linear in x (x = vector positions, xq = where it is wanted)
m = 0.5 + 0.4 * xq / max(x(:));
end

function m = uncertainty_truth(yq, y)
% uncertainty in px per frame: 0.01 + 0.001 * row number of the vector grid (linear in y)
step = y(2, 1) - y(1, 1);
m = 0.01 + 0.001 * ((yq - y(1, 1)) / step + 1);
end

function set_calibration(c, sz)
% the calibration controls of the PIVlab window, applied without dialogs
h = gui.gethand;
set(h.x_axis_direction, 'Value', c.xdir);
set(h.y_axis_direction, 'Value', c.ydir);
data = struct('pointscali', [], 'points_offsetx', [], 'points_offsety', [], 'size_of_the_image', sz);
switch c.kind
    case 'px'
        set(h.realdist, 'String', '1');
        set(h.time_inp, 'String', '1');
    case 'ref'
        data.pointscali = [0 0; c.ref(1) 0];
        set(h.realdist, 'String', num2str(c.ref(2) * 1000, 12));
        set(h.time_inp, 'String', num2str(c.dt * 1000, 12));
    otherwise
        data.pointscali = [0 0; c.px_per_m * 0.1 0];   % 100 mm
        set(h.realdist, 'String', '100');
        set(h.time_inp, 'String', num2str(c.dt * 1000, 12));
end
if ~isempty(c.origin)
    data.points_offsetx = [c.origin 0];   % this pixel has x = 0 mm
    data.points_offsety = [c.origin 0];   % and y = 0 mm
end
calibrate.apply_calibration_data(data);
extract.update_choice_lists(h);   % extraction lists with the units (filled when the panel opens)
gui.put('derived', []);
end

function set_polyline(P)
h = gui.gethand;
gui.put('extract_type', 'extract_poly');
gui.put('xposition', P(:, 1));
gui.put('yposition', P(:, 2));
set(h.draw_what, 'Value', 1);
end

function [c, distance, cx, cy] = extract_line(choice)
% poly-line extraction of frame 1 without the plot window (A.Tag = frame number)
h = gui.gethand;
set(h.extraction_choice, 'Value', choice);
A.Tag = 1;
extract.plot_data_Callback(A, [], []);
c = double(gui.retr('c'));
c = c(:);
distance = double(gui.retr('distance'));
distance = distance(:);
cx = double(gui.retr('cx'));
cy = double(gui.retr('cy'));
end

function data = extract_area(choice)
% area extraction of frame 1 without the display ({area, mean, integral}, or one row per circle)
h = gui.gethand;
set(h.extraction_choice_area, 'Value', choice);
data = extract.plot_data_area(1, 0);
end

function L = segment_lengths(P)
L = hypot(diff(P(:, 1)), diff(P(:, 2)));
end

function [px, py, seg] = polyline_points(P, s)
% the points at the distances s (px) along the poly-line P, and the segment of every point
L = segment_lengths(P);
start = [0; cumsum(L)];
seg = zeros(size(s));
for i = 1:numel(s)
    seg(i) = min(numel(L), find(s(i) >= start - 1e-9, 1, 'last'));
end
t = (s - start(seg)) ./ L(seg);
px = P(seg, 1) + t .* (P(seg + 1, 1) - P(seg, 1));
py = P(seg, 2) + t .* (P(seg + 1, 2) - P(seg, 2));
end

function ok = away_from_bends(P, s, dist)
% true for the points that are more than dist (px) away from every bend of the poly-line
start = cumsum(segment_lengths(P));
ok = true(size(s));
for b = 1:numel(start) - 1
    ok = ok & abs(s - start(b)) > dist;
end
end

function verify_angle(testCase, actual, expected, tol_deg, label)
% angles in degrees: the difference is taken on the circle
d = mod(double(actual(:)) - double(expected(:)) + 180, 360) - 180;
testCase.verifyFalse(any(isnan(d)), [label ': NaN']);
testCase.verifyLessThanOrEqual(max(abs(d)), tol_deg, sprintf('%s: largest deviation %.4g degrees', label, max(abs(d))));
end
