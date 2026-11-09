%% Tests for the ChArUco board as print-ready PDF (preproc.cam_board_pdf)
%
% The filled paths of the PDF are drawn into pixel images (layer "Farbe" and layer "weiss") and
% compared with generateCharucoBoard at the same size: every pixel of the board must be equal,
% the two layers must not overlap and leave no gap. The QR codes must be readable. The TIFF
% logo must be where the PDF logo is. If Inkscape is installed, the PDF is also rendered by
% Inkscape and the board must be detected with all corners.
%
% Run with:
%   runtests('unittests/test_core_charuco_pdf.m')

function tests = test_core_charuco_pdf
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
addpath(helper_root());
testCase.TestData.folder = tempname;
mkdir(testCase.TestData.folder);
end

function teardownOnce(testCase)
rmdir(testCase.TestData.folder, 's');
end

% -------------------------------------------------------------------------

function test_black_origin(testCase)
% checker 10 mm, marker 6 mm, 60 px per checker: 6 px per marker bit
check_board(testCase, [5 7], 10, 6, 'black', 6);
end

function test_white_origin(testCase)
% checker 12 mm, marker 9 mm, 48 px per checker
check_board(testCase, [8 11], 12, 9, 'white', 4);
end

function test_large_board(testCase)
% 1000 markers: marker IDs and order over the whole dictionary
check_board(testCase, [40 50], 6, 4, 'black', 9);
end

function test_print_settings(testCase)
% spot colour "weiss" with overprint in the top layer "weiss", black = 100 % K, no background
pdf_file = fullfile(testCase.TestData.folder, 'settings.pdf');
preproc.cam_board_pdf(pdf_file, [9 13], 'DICT_4X4_1000', 10, 7, 'black');
txt = fileread(pdf_file);
testCase.verifyTrue(startsWith(txt, '%PDF-1.6'));
testCase.verifyNotEmpty(regexp(txt, '/Separation /weiss /DeviceCMYK', 'once'));
testCase.verifyNotEmpty(regexp(txt, '/GSoverprint << /Type /ExtGState /OP true /op true /OPM 1 >>', 'once'));
testCase.verifyNotEmpty(regexp(txt, '/Type /OCG /Name \(Farbe\)', 'once'));
testCase.verifyNotEmpty(regexp(txt, '/Type /OCG /Name \(weiss\)', 'once'));
stream = pdf_stream(txt);
i_farbe = strfind(stream, '/OC /OCfarbe BDC');
i_weiss = strfind(stream, '/OC /OCweiss BDC');
testCase.assertNumElements(i_farbe, 1);
testCase.assertNumElements(i_weiss, 1);
testCase.verifyGreaterThan(i_weiss, i_farbe, '"weiss" must be the top layer (drawn last)');
weiss = stream(i_weiss:end);
testCase.verifyNotEmpty(strfind(weiss, '/GSoverprint gs'));
testCase.verifyNotEmpty(strfind(weiss, '/CSweiss cs 1 scn'));
testCase.verifyEmpty(regexp(weiss, ' k\n', 'once'), 'no process colour in layer "weiss"');
testCase.verifyNotEmpty(strfind(stream(1:i_weiss), sprintf('\n0 0 0 1 k\n')), 'black = 100 %% K');
% cross-reference table: every offset points to its object
xref = regexp(txt, 'xref\n0 (\d+)\n(.*?)trailer', 'tokens', 'once');
offsets = sscanf(xref{2}, '%d %d %c');
offsets = reshape(offsets, 3, [])';
for k = 2:size(offsets, 1)
    testCase.verifyTrue(startsWith(txt(offsets(k, 1) + 1:end), sprintf('%d 0 obj', k - 1)), sprintf('xref of object %d', k - 1));
end
start = str2double(regexp(txt, 'startxref\n(\d+)', 'tokens', 'once'));
testCase.verifyTrue(startsWith(txt(start + 1:end), 'xref'));
len = str2double(regexp(txt, '8 0 obj\n(\d+)', 'tokens', 'once'));
testCase.verifyEqual(len, numel(stream));
end

function test_no_overlap(testCase)
% layer "Farbe" and layer "weiss": no overlap, no gap, black board as generateCharucoBoard
dims = [9 13];
S = 10;
M = 6;
px_per_mm = 10; % 10 px per marker bit
pdf_file = fullfile(testCase.TestData.folder, 'no_overlap.pdf');
preproc.cam_board_pdf(pdf_file, dims, 'DICT_4X4_1000', S, M, 'black');
[farbe, weiss] = draw_layers(fileread(pdf_file), px_per_mm, true);
testCase.verifyEqual(nnz(farbe & weiss), 0, 'Farbe and weiss overlap');
testCase.verifyEqual(nnz(~farbe & ~weiss), 0, 'Points without ink on the page (board and bleed)');
[farbe, weiss] = draw_layers(fileread(pdf_file), px_per_mm);
testCase.verifyEqual(nnz(~farbe & ~weiss), 0, 'Points without ink on the board');
mg_px = 3 * S * px_per_mm;
ref = generateCharucoBoard(dims * S * px_per_mm + 2 * mg_px, dims, 'DICT_4X4_1000', S * px_per_mm, M * px_per_mm, ...
    'OriginCheckerColor', 'black', 'MinMarkerID', 0, 'MarginSize', mg_px);
board = mg_px + 1:size(ref, 1) - mg_px;
board_c = mg_px + 1:size(ref, 2) - mg_px;
testCase.verifyEqual(nnz(farbe(board, board_c) ~= (ref(board, board_c) == 0)), 0, 'Black board differs from generateCharucoBoard');
end

function test_tiff_logo_as_pdf(testCase)
% the TIFF board (preproc.cam_decorate_board) draws the logo at the same place as the PDF
dims = [9 13];
S = 10;
M = 6;
px_per_mm = 10;
pdf_file = fullfile(testCase.TestData.folder, 'logo.pdf');
preproc.cam_board_pdf(pdf_file, dims, 'DICT_4X4_1000', S, M, 'black');
farbe = draw_layers(fileread(pdf_file), px_per_mm);
mg_px = 3 * S * px_per_mm;
I = double(generateCharucoBoard(dims * S * px_per_mm + 2 * mg_px, dims, 'DICT_4X4_1000', S * px_per_mm, M * px_per_mm, ...
    'OriginCheckerColor', 'black', 'MinMarkerID', 0, 'MarginSize', mg_px)) / 255;
I = preproc.cam_decorate_board(I, dims, 'DICT_4X4_1000', S, M, 'black', mg_px, px_per_mm, true);
% only the bottom margin between the QR codes: there is only the logo
logo_area = false(size(I));
logo_area(end - mg_px + 1:end, mg_px + 1:end - mg_px) = true;
ink = farbe & logo_area;
testCase.assertGreaterThan(nnz(ink), 1000);
inside = imerode(ink, true(3)); % pixels fully inside the logo / fully outside it
outside = ~imdilate(ink, true(3)) & logo_area;
testCase.verifyLessThan(max(I(inside)), 0.95, 'TIFF logo missing where the PDF logo is');
testCase.verifyEqual(min(I(outside)), 1, 'TIFF logo where the PDF has no logo');
end

function test_inkscape_detection(testCase)
inkscape = 'C:\Program Files\Inkscape\bin\inkscape.com';
testCase.assumeTrue(isfile(inkscape), 'Inkscape not installed');
dims = [9 13];
pdf_file = fullfile(testCase.TestData.folder, 'inkscape.pdf');
png_file = fullfile(testCase.TestData.folder, 'inkscape.png');
preproc.cam_board_pdf(pdf_file, dims, 'DICT_4X4_1000', 10, 7, 'black');
% transparent material in front of a dark background; without anti-aliasing (it mixes the
% background into pixels on colour/white edges): no background on the board
status = system(['"' inkscape '" "' pdf_file '" --pdf-poppler --export-type=png --export-dpi=600 --export-png-antialias=0 --export-background=#303030 --export-background-opacity=1 --export-filename="' png_file '"']);
testCase.assertEqual(status, 0);
img = imread(png_file);
testCase.verifyEqual(nnz(img(:, :, 1) == 48 & img(:, :, 2) == 48 & img(:, :, 3) == 48), 0, 'Background visible on the board (gap between Farbe and weiss)');
status = system(['"' inkscape '" "' pdf_file '" --pdf-poppler --export-type=png --export-dpi=150 --export-background=#303030 --export-background-opacity=1 --export-filename="' png_file '"']);
testCase.assertEqual(status, 0);
img = imread(png_file);
if size(img, 3) == 3
    img = rgb2gray(img);
end
P = detectCharucoBoardPoints(img, dims, 'DICT_4X4_1000', 10, 7, 'OriginCheckerColor', 'black');
testCase.verifyEqual(nnz(all(isfinite(P), 2)), prod(dims - 1));
% corner spacing = 10 mm at 150 dpi
d = vecnorm(diff(P(1:dims(1) - 1, :)), 2, 2);
testCase.verifyEqual(mean(d), 10 * 150 / 25.4, 'AbsTol', 0.05);
end

% -------------------------------------------------------------------------

function check_board(testCase, dims, S, M, origin, px_per_mm)
pdf_file = fullfile(testCase.TestData.folder, sprintf('board_%dx%d_%s.pdf', dims(1), dims(2), origin));
preproc.cam_board_pdf(pdf_file, dims, 'DICT_4X4_1000', S, M, origin);
txt = fileread(pdf_file);

% page size = board + 5 mm bleed on every side, in mm; no other page box (the page is the document size)
margin = 3 * S;
media = pdf_box(txt, 'MediaBox') * 25.4 / 72;
testCase.verifyEqual(media, [0 0 [dims(2) * S dims(1) * S] + 2 * margin + 10], 'AbsTol', 1e-4);
testCase.verifyEmpty(regexp(txt, '/(TrimBox|BleedBox|CropBox|ArtBox)', 'once'));

% black board
farbe = draw_layers(txt, px_per_mm);
mg_px = round(margin * px_per_mm);
ref = generateCharucoBoard(dims * S * px_per_mm + 2 * mg_px, dims, 'DICT_4X4_1000', S * px_per_mm, M * px_per_mm, ...
    'OriginCheckerColor', origin, 'MinMarkerID', 0, 'MarginSize', mg_px);
board = mg_px + 1:size(ref, 1) - mg_px;
board_c = mg_px + 1:size(ref, 2) - mg_px;
testCase.verifyEqual(nnz(farbe(board, board_c) ~= (ref(board, board_c) == 0)), 0, 'Board pixels differ from generateCharucoBoard');

% QR code in the top left corner
corner = uint8(~farbe(1:mg_px, 1:mg_px)) * 255;
corner = padarray(corner, [mg_px mg_px], 255, 'both'); % quiet zone
[ok, ~, qr_origin, qr_dims, qr_S, qr_M] = preproc.cam_get_charuco_info_from_QRcode(imresize(corner, 4, 'nearest'));
testCase.verifyEqual(ok, 1);
testCase.verifyEqual(lower(char(qr_origin)), lower(origin));
testCase.verifyEqual(double(qr_dims(:)'), dims);
testCase.verifyEqual(double([qr_S qr_M]), [S M]);
end

function stream = pdf_stream(txt)
i0 = strfind(txt, sprintf('stream\n'));
i1 = strfind(txt, 'endstream');
stream = txt(i0(1) + 7:i1(1) - 1);
end

function v = pdf_box(txt, name)
% page box [x0 y0 x1 y1] in points
v = regexp(txt, ['/' name ' \[([^\]]*)\]'], 'tokens', 'once');
v = sscanf(v{1}, '%f')';
end

function [farbe, weiss] = draw_layers(txt, px_per_mm, with_bleed)
% pixel images of layer "Farbe" and layer "weiss" (pixel centres inside a filled area are true);
% the whole page (with_bleed = true) or only the board (page without 5 mm bleed, default)
if nargin < 3
    with_bleed = false;
end
media = pdf_box(txt, 'MediaBox');
pg.k = 72 / 25.4;
trim = media + [5 5 -5 -5] * pg.k;
pg.H = media(4) / pg.k;
pg.px = px_per_mm;
sz = round([media(4) media(3)] / pg.k * px_per_mm);
stream = pdf_stream(txt);
i_weiss = strfind(stream, '/OC /OCweiss BDC');
farbe = draw_fills(stream(1:i_weiss - 1), sz, pg);
weiss = draw_fills(stream(i_weiss:end), sz, pg);
if ~with_bleed
    rows = round((media(4) - trim(4)) / pg.k * px_per_mm) + 1:round((media(4) - trim(2)) / pg.k * px_per_mm);
    cols = round(trim(1) / pg.k * px_per_mm) + 1:round(trim(3) / pg.k * px_per_mm);
    farbe = farbe(rows, cols);
    weiss = weiss(rows, cols);
end
end

function img = draw_fills(stream, sz, pg)
% all fills (f*, rule even-odd) of a part of the content stream; the fills are combined
img = false(sz);
fills = strsplit(stream, 'f*');
for f = 1:numel(fills)
    filled = false(sz);
    lines = splitlines(fills{f});
    poly = [];
    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if isempty(line)
            continue
        end
        v = sscanf(line, '%f');
        if endsWith(line, ' re')
            % rectangle: x y w h in points, y up -> pixel rows and columns
            x1 = v(1) / pg.k * pg.px;
            x2 = (v(1) + v(3)) / pg.k * pg.px;
            y1 = (pg.H - (v(2) + v(4)) / pg.k) * pg.px;
            y2 = (pg.H - v(2) / pg.k) * pg.px;
            rows = round(y1) + 1:round(y2);
            cols = round(x1) + 1:round(x2);
            filled(rows, cols) = ~filled(rows, cols);
        elseif endsWith(line, ' m')
            poly = v(1:2)';
        elseif endsWith(line, ' l')
            poly(end + 1, :) = v(1:2)'; %#ok<AGROW>
        elseif strcmp(line, 'h')
            x = poly(:, 1) / pg.k * pg.px + 0.5; % poly2mask: pixel centres at integer coordinates
            y = (pg.H - poly(:, 2) / pg.k) * pg.px + 0.5;
            c0 = max(1, floor(min(x)));
            c1 = min(sz(2), ceil(max(x)));
            r0 = max(1, floor(min(y)));
            r1 = min(sz(1), ceil(max(y)));
            inside = poly2mask(x - c0 + 1, y - r0 + 1, r1 - r0 + 1, c1 - c0 + 1);
            filled(r0:r1, c0:c1) = xor(filled(r0:r1, c0:c1), inside);
            poly = [];
        end
    end
    img = img | filled;
end
end
