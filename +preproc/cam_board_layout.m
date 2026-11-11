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
%   L.text         text line, L.font_size its font size (em, Archivo Black: preproc.cam_board_text)
%   L.text_x, L.text_y  left end of the baseline of the text (the ink starts at the left edge of
%                  the checker pattern and is centred vertically in the top margin)
%   L.logo_x, L.logo_y  top left corner of the logo, L.logo_width, L.logo_height its size
%   L.axes         board coordinate system (origin, x, y, z) in the left and bottom margin:
%                  L.axes.origin, .shape (arrows, z symbol: polyshape), .labels, see axes_layout below
rows = patternDims(1);
cols = patternDims(2);
S = checkerSize;
L.margin = max(0.5 * S, 5);

% text (left) and logo (right, as high as the font size), one margin apart, together as wide as
% the checker pattern; the text width from its outlines
L.text = [char(originCheckerColor) '; ' char(markerFamily) '; ' num2str(rows) 'x' num2str(cols) '; ' num2str(S) 'mm/' num2str(markerSize) 'mm'];
ink = text_ink(L.text);
logo_txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo_vector.svg'));
logo_box = regexp(logo_txt, 'viewBox="([^"]*)"', 'tokens', 'once');
logo_box = sscanf(logo_box{1}, '%f');
logo_aspect = logo_box(3) / logo_box(4);
L.font_size = (cols * S - L.margin) / (ink.width + logo_aspect);
L.font_size = min(L.font_size, 200 * 25.4 / 300); % max. 16.9 mm: header not taller on large boards
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

L.axes = axes_layout(L, rows, cols, S);
end

function A = axes_layout(L, rows, cols, S)
% Coordinate system of the board, as patternWorldPoints / detectCharucoBoardPoints and
% stereo.calibrate use it: origin = first inner corner (top left), x to the right, y down, z into
% the board. Drawn in the left and bottom margin only (the checker pattern stays as it is, the
% detection is not affected): in the left margin a tick at the row line through the origin and an
% arrow down (y), in the bottom margin a tick at the column line through the origin and an arrow to
% the right (x), labels '0', 'y', 'x', and in the bottom left corner the z axis as a circle with a
% cross (pointing into the board) with label 'z'. All sizes in units of the margin.
%   A.origin     [x y] of the origin [mm]
%   A.shape      arrows and z symbol as one polyshape (vector outlines, mm, y down); regions do not
%                overlap, holes are holes
%   A.labels     .text, .origin (left end of the baseline, mm) of the labels; A.font_size [mm]
%                (board font, preproc.cam_board_text)
% Empty shape and labels: the checkers are too small for the axes (no room in the margin).
m = L.margin;
A.origin = [m + S, L.margin_top + S];
A.shape = polyshape();
A.labels = struct('text', {}, 'origin', {});
A.font_size = 0.7 * m;
if S < 0.6 * m || (rows - 1) * S < 1.7 * m || cols < 2
    return
end
O = A.origin;
w = 0.1 * m; % line width
hl = 0.4 * m; % arrow head length
hw = 0.2 * m; % arrow head half width
c = 0.4 * m; % shafts 0.4 margin from the board edge, 0.6 margin from the checker pattern
t = 0.15 * m; % gap between the ticks and the checker pattern
B = L.margin_top + rows * S; % bottom edge of the checker pattern
preferred = S * max(1, ceil(1.2 * m / S)); % arrow length: whole checkers, at least 1.2 margins
len_y = max(0.6 * m, min(preferred, (rows - 1) * S - 1.1 * m)); % label 'y' clear of label 'z'
len_x = max(0.6 * m, min(preferred, (cols - 1) * S + 0.2 * m)); % label 'x' on the board
% y: left margin, tick at the row line through the origin, arrow down
yt = O(2) + len_y;
yh = yt - hl;
arrow_y = polyshape([c - w / 2, O(2) - w / 2; m - t, O(2) - w / 2; m - t, O(2) + w / 2; c + w / 2, O(2) + w / 2; ...
    c + w / 2, yh; c + hw, yh; c, yt; c - hw, yh; c - w / 2, yh]);
% x: bottom margin, tick at the column line through the origin, arrow to the right
yc = B + m - c;
xt = O(1) + len_x;
xh = xt - hl;
arrow_x = polyshape([O(1) - w / 2, B + t; O(1) + w / 2, B + t; O(1) + w / 2, yc - w / 2; xh, yc - w / 2; ...
    xh, yc - hw; xt, yc; xh, yc + hw; xh, yc + w / 2; O(1) - w / 2, yc + w / 2]);
A.shape = union([arrow_y, arrow_x, into_board([c, yc], 0.3 * m, 0.08 * m)]);
% labels, centred (outline) at these points
centres = {'0', [c, O(2) - 0.5 * m]; 'y', [c, yt + 0.45 * m]; '0', [O(1) - 0.5 * m, yc]; ...
    'x', [xt + 0.45 * m, yc]; 'z', [c, yc - 0.65 * m]};
for k = 1:size(centres, 1)
    [~, ~, e] = preproc.cam_board_text(centres{k, 1}, A.font_size, [0 0]);
    A.labels(k) = struct('text', centres{k, 1}, 'origin', centres{k, 2} - [e(1) + e(2), e(3) + e(4)] / 2);
end
end

function s = into_board(centre, radius, line_width)
% circle with a cross: axis pointing into the board
a = linspace(0, 2 * pi, 97)';
a(end) = [];
ring = subtract(polyshape(centre(1) + radius * cos(a), centre(2) + radius * sin(a)), ...
    polyshape(centre(1) + (radius - line_width) * cos(a), centre(2) + (radius - line_width) * sin(a)));
d = (radius - line_width / 2) / sqrt(2); % the cross ends in the middle of the ring
cross = [polybuffer(centre + [-d -d; d d], 'lines', line_width / 2), polybuffer(centre + [-d d; d -d], 'lines', line_width / 2)];
s = union([ring, cross]);
end

function ink = text_ink(txt)
% extent of the outlines of the text in em (preproc.cam_board_text), relative to the left end of the
% baseline: left = ink start right of it, width, height, centre = ink centre below it (y down)
[~, ~, e] = preproc.cam_board_text(txt, 1, [0 0]);
ink.left = e(1);
ink.width = e(2) - e(1);
ink.height = e(4) - e(3);
ink.centre = (e(3) + e(4)) / 2;
end
