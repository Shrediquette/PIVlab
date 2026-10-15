function I = cam_decorate_board(I, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor, marginsize, px_per_mm, grayscale)
% QR code (in all four corners), Optolution logo (bottom) and a text line with the board
% parameters (top) in the margin of a ChArUco board image, as on the boards that PIVlab prints
% (Setup / define / generate marker board). Also used by the synthetic image generator
% (simulate.board_texture), so that the simulated board looks like the printed one.
% I:          board image, double 0..1 (white = 1), from generateCharucoBoard with MarginSize = marginsize
% marginsize: width of the white margin [px]; the QR codes fill the margin
% px_per_mm:  image resolution [px/mm] (e.g. 300 dpi / 25.4); the font size scales with it
% grayscale:  true: the result is a grayscale image (logo in gray); default false: RGB (colour logo)
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

%% logo at the bottom
olt_logo = double(imread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo.png'))) / 255;
if grayscale && size(olt_logo, 3) == 3
    olt_logo = rgb2gray(olt_logo);
end
olt_logo = padarray(olt_logo, [50 50], 1, 'both');
max_width = floor(patternDims(2) * checkerSize * px_per_mm);
max_height = q;

olt_width1 = floor(size(olt_logo, 2) / size(olt_logo, 1) * max_height);
oltsize1 = [max_height olt_width1];

olt_height1 = floor(size(olt_logo, 1) / size(olt_logo, 2) * max_width);
oltsize2 = [olt_height1 max_width];

oltsize = oltsize1;
if olt_width1 > max_width
    oltsize = oltsize2;
end
if olt_height1 > max_height
    oltsize = oltsize1;
end
olt_logo = imresize(olt_logo, [oltsize(1) oltsize(2)], 'bicubic');
if size(olt_logo, 3) == 3
    I = repmat(I, 1, 1, 3);
end
rows = imageSize(1) - oltsize(1) + 1:imageSize(1);
cols = floor((imageSize(2) - oltsize(2)) / 2) + (1:oltsize(2));
I(rows, cols, :) = I(rows, cols, :) .* olt_logo;

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
