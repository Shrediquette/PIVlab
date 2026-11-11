function L = cam_board_layout(patternDims, markerFamily, checkerSize, markerSize, originCheckerColor)
% Layout of the ChArUco boards that PIVlab prints (TIFF, PDF) and simulates (simulate.board_texture):
% a thin white margin, the QR code in place of the central 2 x 2 checkers, and in a taller top
% margin the text with the board parameters (left) and the logo (images/OLT_logo_vector.svg, right).
% Text and logo together span the width of the checker pattern.
% patternDims: [rows columns]; checkerSize, markerSize in mm.
% All lengths in mm, x to the right and y down from the top left corner of the board (with margin).
%   L.margin       width of the white margin left, right and at the bottom
%   L.margin_top   height of the top margin (text and logo), whole mm
%   L.width        board width with margins, L.height alike
%   L.qr_rows      checker rows replaced by the QR code (1 = first row), L.qr_cols alike
%   L.qr_x, L.qr_y top left corner of the QR code, L.qr_size its width (= 2 checkers, with quiet zone)
%   L.qr_data      text in the QR code, e.g. 'F:1,O:b,R:11,C:12,S:12,M:9'
%   L.text         text line, L.font_size its font size (Arial Black)
%   L.text_x, L.text_y  anchor point of the text for insertText with AnchorPoint 'LeftCenter'
%                  (the ink starts at the left edge of the checker pattern and is centred vertically)
%   L.logo_x, L.logo_y  top left corner of the logo, L.logo_width, L.logo_height its size
rows = patternDims(1);
cols = patternDims(2);
S = checkerSize;
L.margin = max(0.5 * S, 5);

% text (left) and logo (right, as high as the font size), one margin apart, together as wide as
% the checker pattern; the text width from its ink in a rendering with a large font
L.text = [char(originCheckerColor) '; ' char(markerFamily) '; ' num2str(rows) 'x' num2str(cols) '; ' num2str(S) 'mm/' num2str(markerSize) 'mm'];
ink = text_ink(L.text);
logo_txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo_vector.svg'));
logo_box = regexp(logo_txt, 'viewBox="([^"]*)"', 'tokens', 'once');
logo_box = sscanf(logo_box{1}, '%f');
logo_aspect = logo_box(3) / logo_box(4);
L.font_size = (cols * S - L.margin) / (ink.width + logo_aspect);
L.font_size = min(L.font_size, 200 * 25.4 / 300); % insertText: max. 200 px font size at 300 dpi (TIFF)
L.logo_height = L.font_size;
L.logo_width = L.logo_height * logo_aspect;
content = max(ink.height * L.font_size, L.logo_height);
L.margin_top = max(L.margin, ceil(content / 0.8)); % text and logo fill 80 % of the top margin
L.width = cols * S + 2 * L.margin;
L.height = rows * S + L.margin + L.margin_top;
L.text_x = L.margin - ink.left * L.font_size;
L.text_y = L.margin_top / 2 - ink.centre * L.font_size;
L.logo_x = L.width - L.margin - L.logo_width;
L.logo_y = (L.margin_top - L.logo_height) / 2;

% QR code: central 2 x 2 checkers (half a checker towards the origin for an odd number of rows / columns)
r0 = floor((rows - 2) / 2) + 1;
c0 = floor((cols - 2) / 2) + 1;
L.qr_rows = [r0 r0 + 1];
L.qr_cols = [c0 c0 + 1];
L.qr_x = L.margin + (c0 - 1) * S;
L.qr_y = L.margin_top + (r0 - 1) * S;
L.qr_size = 2 * S;
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
L.qr_data = ['F:' num2str(qr_fam) ',O:' qr_orig ',R:' num2str(rows) ',C:' num2str(cols) ',S:' num2str(S) ',M:' num2str(markerSize)];
end

function ink = text_ink(txt)
% extent of the ink of the text (Arial Black) in font sizes, for insertText with AnchorPoint
% 'LeftCenter': left = ink start right of the anchor, width, height, centre = ink centre below the anchor
fs = 150;
x0 = 20;
y0 = 150;
img = insertText(ones(300, ceil(numel(txt) * fs) + 2 * x0), [x0 y0], txt, 'FontSize', fs, 'Font', 'Arial Black', ...
    'FontColor', 'black', 'TextBoxColor', 'white', 'BoxOpacity', 0, 'AnchorPoint', 'LeftCenter');
mask = img(:, :, 1) < 0.5;
c = find(any(mask, 1));
r = find(any(mask, 2));
ink.left = (c(1) - 1 - x0) / fs;
ink.width = (c(end) - c(1) + 1) / fs;
ink.height = (r(end) - r(1) + 1) / fs;
ink.centre = ((r(1) - 1 + r(end)) / 2 - y0) / fs;
end
