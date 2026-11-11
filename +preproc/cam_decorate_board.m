function I = cam_decorate_board(I, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor, marginsize, px_per_mm, grayscale)
% QR code (in place of the central 2 x 2 checkers), a text line with the board parameters (top
% left), the Optolution logo (top right) and the board coordinate system (origin, x, y, z; left
% and bottom margin) on a ChArUco board image, as on the boards that PIVlab prints (Setup /
% define / generate marker board). Layout: preproc.cam_board_layout.
% Also used by the synthetic image generator (simulate.board_texture), so that the simulated board
% looks like the printed one.
% I:          board image, double 0..1 (white = 1), from generateCharucoBoard with MarginSize = marginsize
% marginsize: width of the white margin [px]
% px_per_mm:  image resolution [px/mm] (e.g. 300 dpi / 25.4)
% grayscale:  true: the result is a grayscale image (logo in gray); default false: RGB (colour logo)
% The result has a taller top margin (text and logo) of q_top pixels: white rows are added at the top.
% The logo is drawn from images/OLT_logo_vector.svg at the image resolution.
if nargin < 9
    grayscale = false;
end
L = preproc.cam_board_layout(patternDims, markerFamily, checkerSize, markerSize, originCheckerColor);
q = marginsize;
q_top = top_margin_px(L, q, px_per_mm);
I = [ones(q_top - q, size(I, 2)); I];
imageSize = size(I, [1 2]);
cpx = checkerSize * px_per_mm; % pixels per checker

%% QR code in place of the central 2 x 2 checkers
% generateCharucoBoard rounds the checker edges in its own way: the pixels of the 2 x 2 checkers
% are taken from the image, as the bounding box of its two black checkers (4-connected: black
% checkers only touch at their corners)
qr_r = [];
qr_c = [];
for r = L.qr_rows
    for c = L.qr_cols
        centre = [q_top + round((r - 0.5) * cpx), q + round((c - 0.5) * cpx)];
        if I(centre(1), centre(2)) < 0.5
            checker = bwselect(I < 0.5, centre(2), centre(1), 4);
            [rows_k, cols_k] = find(checker);
            qr_r = [qr_r min(rows_k) max(rows_k)]; %#ok<AGROW>
            qr_c = [qr_c min(cols_k) max(cols_k)]; %#ok<AGROW>
        end
    end
end
qr_r = min(qr_r):max(qr_r);
qr_c = min(qr_c):max(qr_c);
qr = double(preproc.cam_encode_qr(L.qr_data, numel(qr_r))); % 1 = white
if ~isempty(qr)
    I(qr_r, qr_c) = imresize(qr, [numel(qr_r) numel(qr_c)], 'nearest');
end

%% board coordinate system (origin, axes) in the left and bottom margin (as in preproc.cam_board_pdf)
% mm -> px relative to the checker pattern as generateCharucoBoard drew it (its edges rounded to pixels)
ss = 4; % 4 x 4 samples per pixel (smooth edges)
sx = (imageSize(2) - 2 * q) / (patternDims(2) * checkerSize); % [px/mm]
sy = (imageSize(1) - q_top - q) / (patternDims(1) * checkerSize);
px_x = @(x) q + (x - L.margin) * sx; % px, 0 = left image edge
px_y = @(y) q_top + (y - L.margin_top) * sy; % px, 0 = top image edge
axes_regions = regions(L.axes.shape); % arrows and z symbol; one region (with its holes) at a time
for k = 1:numel(axes_regions)
    polys = cell(1, numboundaries(axes_regions(k)));
    for b = 1:numel(polys)
        [x, y] = boundary(axes_regions(k), b);
        polys{b} = [x, y];
    end
    I = fill_black(I, polys, px_x, px_y, ss);
end
for k = 1:numel(L.axes.labels) % labels in the board font
    [~, polys] = preproc.cam_board_text(L.axes.labels(k).text, L.axes.font_size, L.axes.labels(k).origin);
    I = fill_black(I, polys, px_x, px_y, ss);
end

%% logo top right, drawn from the vector logo (same size and position as in preproc.cam_board_pdf)
logo_txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo_vector.svg'));
logo_box = regexp(logo_txt, 'viewBox="([^"]*)"', 'tokens', 'once');
logo_box = sscanf(logo_box{1}, '%f');
logo_colours = regexp(logo_txt, '<path fill="#([0-9a-f]{6})"[^>]* d="([^"]*)"', 'tokens');
logo_h = L.logo_height * px_per_mm; % [px]
logo_scale = logo_h / logo_box(4); % [px per logo unit]
logo_x = imageSize(2) - q - L.logo_width * px_per_mm; % left edge [px], 0 = left image edge; right end at the board edge
logo_y = q_top / 2 - logo_h / 2; % centred in the top margin
if ~grayscale
    I = repmat(I, 1, 1, 3);
end
% pixels of the logo box; the colour coverage of every pixel from 4 x 4 samples (smooth edges)
ss = 4;
c0 = max(0, floor(logo_x));
c1 = min(imageSize(2), ceil(logo_x + logo_box(3) * logo_scale));
r0 = max(0, floor(logo_y));
r1 = min(imageSize(1), ceil(logo_y + logo_h));
box = I(r0 + 1:r1, c0 + 1:c1, :);
for k = 1:numel(logo_colours)
    rgb = [hex2dec(logo_colours{k}{1}(1:2)) hex2dec(logo_colours{k}{1}(3:4)) hex2dec(logo_colours{k}{1}(5:6))] / 255;
    if grayscale
        rgb = 0.299 * rgb(1) + 0.587 * rgb(2) + 0.114 * rgb(3);
    end
    mask = false((r1 - r0) * ss, (c1 - c0) * ss);
    subpaths = regexp(logo_colours{k}{2}, 'M[^M]*', 'match');
    for p = 1:numel(subpaths)
        v = sscanf(regexprep(subpaths{p}, '[MLZ]', ' '), '%f');
        % poly2mask: sample centres at integer coordinates
        x = (logo_x + logo_scale * v(1:2:end) - c0) * ss + 0.5;
        y = (logo_y + logo_scale * v(2:2:end) - r0) * ss + 0.5;
        mask = xor(mask, poly2mask(x, y, size(mask, 1), size(mask, 2))); % fill rule evenodd
    end
    coverage = reshape(sum(reshape(mask, ss, []), 1), size(mask, 1) / ss, []); % sum over sample rows
    coverage = reshape(sum(reshape(coverage', ss, []), 1), size(coverage, 2) / ss, [])' / ss^2; % and columns
    for ch = 1:size(box, 3)
        box(:, :, ch) = box(:, :, ch) .* (1 - coverage) + rgb(ch) * coverage;
    end
end
I(r0 + 1:r1, c0 + 1:c1, :) = box;

%% text with the board parameters top left, outlines of the board font (as in preproc.cam_board_pdf)
if round(L.font_size * px_per_mm) >= 4 && q_top >= 1 % a smaller text would be unreadable anyway
    [~, polys] = preproc.cam_board_text(L.text, L.font_size, [L.text_x, L.text_y]);
    % ink from the left board edge, centred in the top margin (as the logo)
    I = fill_black(I, polys, @(x) q + (x - L.margin) * px_per_mm, @(y) q_top / 2 + (y - L.margin_top / 2) * px_per_mm, ss);
end
end

function I = fill_black(I, polys, px_x, px_y, ss)
% fills closed polygons (mm, fill rule even-odd) black; px_x, px_y: mm -> px (0 = image edge);
% coverage of every pixel from ss x ss samples (smooth edges)
pts = vertcat(polys{:});
if isempty(pts)
    return
end
imageSize = size(I, [1 2]);
[r0, r1, c0, c1] = px_box(px_x([min(pts(:, 1)) max(pts(:, 1))]), px_y([min(pts(:, 2)) max(pts(:, 2))]), imageSize);
mask = false((r1 - r0) * ss, (c1 - c0) * ss);
for k = 1:numel(polys)
    % poly2mask: sample centres at integer coordinates
    mask = xor(mask, poly2mask((px_x(polys{k}(:, 1)) - c0) * ss + 0.5, (px_y(polys{k}(:, 2)) - r0) * ss + 0.5, size(mask, 1), size(mask, 2)));
end
I(r0 + 1:r1, c0 + 1:c1, :) = I(r0 + 1:r1, c0 + 1:c1, :) .* (1 - block_mean(mask, ss));
end

function q_top = top_margin_px(L, q, px_per_mm)
% height of the top margin [px]
q_top = max(q, round(L.margin_top * px_per_mm));
end

function [r0, r1, c0, c1] = px_box(x, y, imageSize)
% whole pixels around x = [left right], y = [top bottom] (px, 0 = image edge), inside the image;
% pixel rows r0 + 1 : r1, columns c0 + 1 : c1
c0 = max(0, floor(x(1)));
c1 = min(imageSize(2), max(c0, ceil(x(2))));
r0 = max(0, floor(y(1)));
r1 = min(imageSize(1), max(r0, ceil(y(2))));
end

function cov = block_mean(mask, ss)
% mean of ss x ss blocks of samples: ink coverage of every pixel
cov = reshape(sum(reshape(mask, ss, []), 1), size(mask, 1) / ss, []); % sum over sample rows
cov = reshape(sum(reshape(cov', ss, []), 1), size(cov, 2) / ss, [])' / ss^2; % and columns
end
