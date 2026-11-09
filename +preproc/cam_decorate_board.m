function I = cam_decorate_board(I, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor, marginsize, px_per_mm, grayscale)
% QR code (in all four corners), Optolution logo (bottom) and a text line with the board
% parameters (top) in the margin of a ChArUco board image, as on the boards that PIVlab prints
% (Setup / define / generate marker board). Also used by the synthetic image generator
% (simulate.board_texture), so that the simulated board looks like the printed one.
% I:          board image, double 0..1 (white = 1), from generateCharucoBoard with MarginSize = marginsize
% marginsize: width of the white margin [px]; the QR codes fill the margin
% px_per_mm:  image resolution [px/mm] (e.g. 300 dpi / 25.4); the font size scales with it
% grayscale:  true: the result is a grayscale image (logo in gray); default false: RGB (colour logo)
% The logo is drawn from images/OLT_logo_vector.svg at the image resolution.
if nargin < 9
    grayscale = false;
end
imageSize = size(I, [1 2]);
if strcmp(markerFamily, 'DICT_4X4_1000')
    qr_fam = 1;
else
    qr_fam = 0;
end
if strcmpi(originCheckerColor, 'white')
    qr_orig = 'w';
else
    qr_orig = 'b';
end
data = ['F:' num2str(qr_fam) ',O:' qr_orig ',R:' num2str(patternDims(1)) ',C:' num2str(patternDims(2)) ',S:' num2str(checkerSize) ',M:' num2str(markerSize)];

%% QR codes in the corners (upright at the top, turned by 180 degrees at the bottom)
q = marginsize;
qr_0 = double(preproc.cam_encode_qr(data, q));
qr_180 = rot90(qr_0, 2);
top = 1:q;
bottom = imageSize(1) - q + 1:imageSize(1);
left = 1:q;
right = imageSize(2) - q + 1:imageSize(2);
I(top, left) = I(top, left) .* qr_0;
I(top, right) = I(top, right) .* qr_0;
I(bottom, left) = I(bottom, left) .* qr_180;
I(bottom, right) = I(bottom, right) .* qr_180;

%% logo at the bottom, drawn from the vector logo (same size and position as in preproc.cam_board_pdf)
logo_txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo_vector.svg'));
logo_box = regexp(logo_txt, 'viewBox="([^"]*)"', 'tokens', 'once');
logo_box = sscanf(logo_box{1}, '%f');
logo_colours = regexp(logo_txt, '<path fill="#([0-9a-f]{6})"[^>]* d="([^"]*)"', 'tokens');
logo_h = 0.8 * q; % [px]
logo_scale = logo_h / logo_box(4); % [px per logo unit]
max_width = 0.9 * patternDims(2) * checkerSize * px_per_mm;
if logo_box(3) * logo_scale > max_width
    logo_scale = max_width / logo_box(3);
    logo_h = logo_box(4) * logo_scale;
end
logo_x = (imageSize(2) - logo_box(3) * logo_scale) / 2; % left edge [px], 0 = left image edge
logo_y = imageSize(1) - q / 2 - logo_h / 2;
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

%% text with the board parameters at the top
textx = round(imageSize(2) / 2);
texty = round(marginsize / 2);
fntsz = round(min(checkerSize * patternDims(2) / 2.5, 200) * px_per_mm / (300 / 25.4)); % font size at 300 dpi, scaled
fntsz = min(fntsz, 200);
if fntsz >= 4 % a smaller text would be unreadable anyway
    strip = I(top, :, :); % only the top margin (fast for large images)
    strip = insertText(strip, [textx, texty], [char(originCheckerColor) '; ' char(markerFamily) '; ' num2str(patternDims(1)) 'x' num2str(patternDims(2)) '; ' num2str(checkerSize) 'mm/' num2str(markerSize) 'mm'], ...
        'FontSize', fntsz, 'FontColor', 'black', 'TextBoxColor', 'white', 'BoxOpacity', 0, 'Font', 'Arial Black', 'AnchorPoint', 'Center');
    if size(I, 3) == 1
        strip = rgb2gray(strip);
    end
    I(top, :, :) = strip;
end
end
