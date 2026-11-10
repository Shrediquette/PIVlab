function cam_board_pdf(filename, patternDims, markerFamily, checkerSize, markerSize, originCheckerColor)
% Writes a ChArUco board as a print-ready vector PDF. Same layout as the TIFF from
% Setup / define / generate marker board (preproc.cam_board_layout): thin margin, QR code in
% place of the central 2 x 2 checkers, text top left, logo top right. All edges are at
% their exact positions in mm.
% patternDims: [rows columns]; checkerSize, markerSize in mm.
% Also for printing on transparent material (readable from both sides): layer "Farbe" (black =
% 100 % K, logo colours in CMYK) and top layer "weiss" (spot colour "weiss", overprint), no
% background. Every point of the board is covered by exactly one colour (no overlap, no gap).
% Page = board + 5 mm on every side (bleed; no TrimBox / BleedBox, the page size is the document
% size the print shop expects); the white margin fills the bleed.
% The text is a black outline (pixels of 0.05 mm or smaller).
% The marker bits are read from generateCharucoBoard (rendered with enough pixels per bit),
% so marker IDs, order and orientation are the same as in the TIFF board.
rows = patternDims(1);
cols = patternDims(2);
S = checkerSize;
M = markerSize;
layout = preproc.cam_board_layout(patternDims, markerFamily, S, M, originCheckerColor);
margin = layout.margin;
top = layout.margin_top; % top margin (text and logo)
W = layout.width;
H = layout.height;
n_bits = sscanf(markerFamily, 'DICT_%d') + 2; % data bits + black border, e.g. 6 for DICT_4X4
bit = M / n_bits; % bit size in mm
origin_black = strcmpi(originCheckerColor, 'black');
pg.H = H; % board height [mm]: PDF y axis points up
pg.k = 72 / 25.4; % points per mm
pg.b = 5; % bleed on every side [mm]: the PDF page is W + 10 mm by H + 10 mm
weiss_screen = [0 0 0 0]; % CMYK of "weiss" on screen: white (the printer uses white ink)

%% marker bits from the reference board in pixels, at least 8 pixels per marker bit
% (only for reading the marker bits: they are sampled in the bit centres)
pxc = max(ceil(8 * n_bits * S / M), 24); % pixels per checker
pxm = round(pxc * M / S); % pixels per marker
mgpx = pxc;
I = generateCharucoBoard(patternDims * pxc + 2 * mgpx, patternDims, markerFamily, pxc, pxm, ...
    'OriginCheckerColor', originCheckerColor, 'MinMarkerID', 0, 'MarginSize', mgpx);
off_px = (pxc - pxm) / 2;
bit_px = pxm / n_bits;
marker_cells = cell(rows, cols); % black cells of the marker in every white checker
for r = 1:rows
    for c = 1:cols
        if is_black_checker(r, c, origin_black)
            continue
        end
        cells = false(n_bits);
        for i = 1:n_bits
            for j = 1:n_bits
                y0 = mgpx + (r - 1) * pxc + off_px + (i - 0.5) * bit_px;
                x0 = mgpx + (c - 1) * pxc + off_px + (j - 0.5) * bit_px;
                cells(i, j) = I(floor(y0) + 1, floor(x0) + 1) == 0;
            end
        end
        marker_cells{r, c} = cells;
    end
end

%% QR code (27 x 27 modules incl. quiet zone, true = dark) in place of the central 2 x 2 checkers
qr_white = preproc.cam_encode_qr(layout.qr_data, 27);
has_qr = ~isempty(qr_white);
if has_qr
    qr_0 = ~qr_white;
    module = layout.qr_size / size(qr_0, 1);
end
in_qr = false(rows, cols); % checkers replaced by the QR code
in_qr(layout.qr_rows, layout.qr_cols) = true;

%% text with the board parameters at the top, as black outline
font_mm = layout.font_size;
has_text = font_mm * 300 / 25.4 >= 4; % as in the TIFF (300 dpi): a smaller text would be unreadable
txt = layout.text;
if has_text
    text_res = min(20, 200 / font_mm); % [px/mm]; insertText allows max. 200 px font size
    strip = ones(ceil(top * text_res), ceil(W * text_res), 3);
    strip = insertText(strip, [layout.text_x * text_res, layout.text_y * text_res], txt, ...
        'FontSize', round(font_mm * text_res), 'FontColor', 'black', 'TextBoxColor', 'white', 'BoxOpacity', 0, 'Font', 'Arial Black', 'AnchorPoint', 'LeftCenter');
    text_mask = rgb2gray(strip) < 0.5;
end

%% logo top right (polygons, one path per colour, and the outline of the whole logo)
logo_txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'OLT_logo_vector.svg'));
logo_box = regexp(logo_txt, 'viewBox="([^"]*)"', 'tokens', 'once');
logo_box = sscanf(logo_box{1}, '%f');
logo_colours = regexp(logo_txt, '<path fill="#([0-9a-f]{6})"[^>]* d="([^"]*)"', 'tokens');
logo_outline = regexp(logo_txt, '<path id="outline"[^>]* d="([^"]*)"', 'tokens', 'once');
logo_scale = layout.logo_height / logo_box(4);
logo_x = layout.logo_x;
logo_y = layout.logo_y;

%% file: header
fid = fopen(filename, 'w');
if fid < 0
    error('Could not write %s', filename);
end
fprintf(fid, '%%PDF-1.6\n');
fwrite(fid, uint8([37 226 227 207 211 10])); % binary comment: the file contains binary data
offsets = zeros(1, 9);

%% content stream (object 4), its length in object 8
offsets(4) = ftell(fid);
fprintf(fid, '4 0 obj\n<< /Length 8 0 R >>\nstream\n');
stream_start = ftell(fid);

% layer "Farbe": black board, QR code, text (100 % K), logo (CMYK)
fprintf(fid, '/OC /OCfarbe BDC\n0 0 0 1 k\n');
for r = 1:rows
    for c = 1:cols
        if in_qr(r, c)
            continue
        elseif is_black_checker(r, c, origin_black)
            write_rect(fid, pg, margin + (c - 1) * S, top + (r - 1) * S, S, S);
        else
            write_cells(fid, pg, marker_cells{r, c}, margin + (c - 1) * S + (S - M) / 2, top + (r - 1) * S + (S - M) / 2, bit);
        end
    end
end
if has_qr
    write_cells(fid, pg, qr_0, layout.qr_x, layout.qr_y, module);
end
if has_text
    write_cells(fid, pg, text_mask, 0, 0, 1 / text_res);
end
fprintf(fid, 'f*\n');
for k = 1:numel(logo_colours)
    cmyk = rgb_to_cmyk(logo_colours{k}{1});
    fprintf(fid, '%s %s %s %s k\n', num(cmyk(1)), num(cmyk(2)), num(cmyk(3)), num(cmyk(4)));
    write_polygons(fid, pg, logo_colours{k}{2}, logo_x, logo_y, logo_scale);
    fprintf(fid, 'f*\n');
end
fprintf(fid, 'EMC\n');

% top layer "weiss": spot colour with overprint, the complement of layer "Farbe"
% (fill rule even-odd: white checkers minus marker cells, QR area minus dark modules, margin minus
% board, text, logo)
fprintf(fid, '/OC /OCweiss BDC\n/GSoverprint gs\n/CSweiss cs 1 scn\n');
for r = 1:rows
    for c = 1:cols
        if in_qr(r, c) || is_black_checker(r, c, origin_black)
            continue
        end
        write_rect(fid, pg, margin + (c - 1) * S, top + (r - 1) * S, S, S);
        write_cells(fid, pg, marker_cells{r, c}, margin + (c - 1) * S + (S - M) / 2, top + (r - 1) * S + (S - M) / 2, bit);
    end
end
write_rect(fid, pg, layout.qr_x, layout.qr_y, layout.qr_size, layout.qr_size);
if has_qr
    write_cells(fid, pg, qr_0, layout.qr_x, layout.qr_y, module);
end
write_rect(fid, pg, -pg.b, -pg.b, W + 2 * pg.b, H + 2 * pg.b); % the white margin reaches into the bleed
write_rect(fid, pg, margin, top, cols * S, rows * S);
if has_text
    write_cells(fid, pg, text_mask, 0, 0, 1 / text_res);
end
write_polygons(fid, pg, logo_outline{1}, logo_x, logo_y, logo_scale);
fprintf(fid, 'f*\nEMC\n');
stream_length = ftell(fid) - stream_start;
fprintf(fid, 'endstream\nendobj\n');

%% the other objects
media_box = sprintf('[0 0 %s %s]', num((W + 2 * pg.b) * pg.k), num((H + 2 * pg.b) * pg.k));
offsets(1) = ftell(fid);
fprintf(fid, ['1 0 obj\n<< /Type /Catalog /Pages 2 0 R\n' ...
    '/OCProperties << /OCGs [5 0 R 6 0 R] /D << /Name (Ebenen) /Order [5 0 R 6 0 R] /ON [5 0 R 6 0 R] >> >> >>\nendobj\n']);
offsets(2) = ftell(fid);
fprintf(fid, '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n');
offsets(3) = ftell(fid);
fprintf(fid, ['3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox %s\n' ...
    '/Resources << /ColorSpace << /CSweiss 7 0 R >>\n' ...
    '/ExtGState << /GSoverprint << /Type /ExtGState /OP true /op true /OPM 1 >> >>\n' ...
    '/Properties << /OCfarbe 5 0 R /OCweiss 6 0 R >> >>\n' ...
    '/Contents 4 0 R >>\nendobj\n'], media_box);
offsets(5) = ftell(fid);
fprintf(fid, '5 0 obj\n<< /Type /OCG /Name (Farbe) >>\nendobj\n');
offsets(6) = ftell(fid);
fprintf(fid, '6 0 obj\n<< /Type /OCG /Name (weiss) >>\nendobj\n');
offsets(7) = ftell(fid);
fprintf(fid, ['7 0 obj\n[/Separation /weiss /DeviceCMYK\n' ...
    '<< /FunctionType 2 /Domain [0 1] /C0 [0 0 0 0] /C1 [%s %s %s %s] /N 1 >>]\nendobj\n'], ...
    num(weiss_screen(1)), num(weiss_screen(2)), num(weiss_screen(3)), num(weiss_screen(4)));
offsets(8) = ftell(fid);
fprintf(fid, '8 0 obj\n%d\nendobj\n', stream_length);
offsets(9) = ftell(fid);
fprintf(fid, '9 0 obj\n<< /Title (ChArUco board %s) /Creator (PIVlab) /Producer (PIVlab preproc.cam_board_pdf) >>\nendobj\n', txt);

%% cross-reference table and trailer
xref_start = ftell(fid);
fprintf(fid, 'xref\n0 10\n0000000000 65535 f \n');
for k = 1:9
    fprintf(fid, '%010d 00000 n \n', offsets(k));
end
fprintf(fid, 'trailer\n<< /Size 10 /Root 1 0 R /Info 9 0 R >>\nstartxref\n%d\n%%%%EOF\n', xref_start);
fclose(fid);
end

function b = is_black_checker(r, c, origin_black)
b = (mod(r + c, 2) == 0) == origin_black;
end

function cmyk = rgb_to_cmyk(hex)
% hex colour 'rrggbb' to CMYK 0..1 (black #000000 = 100 % K only)
rgb = [hex2dec(hex(1:2)) hex2dec(hex(3:4)) hex2dec(hex(5:6))] / 255;
k = 1 - max(rgb);
if k >= 1
    cmyk = [0 0 0 1];
else
    cmyk = [(1 - rgb - k) / (1 - k), k];
end
end

function write_polygons(fid, pg, d, x0, y0, scale)
% polygon path data (absolute M, L, Z only, y down) moved to (x0, y0) [mm] and scaled
letters = regexp(d, '[MLZ]', 'match');
pieces = regexp(d, '[MLZ]', 'split'); % pieces{k + 1}: numbers after letters{k}
for k = 1:numel(letters)
    if letters{k} == 'Z'
        fprintf(fid, 'h\n');
    else
        v = sscanf(pieces{k + 1}, '%f');
        if letters{k} == 'M'
            op = 'm';
        else
            op = 'l';
        end
        fprintf(fid, '%s %s %s\n', num((pg.b + x0 + scale * v(1)) * pg.k), num((pg.b + pg.H - y0 - scale * v(2)) * pg.k), op);
    end
end
end

function write_cells(fid, pg, cells, x0, y0, cell_size)
% black cells as rectangles, horizontal runs of black cells merged into one rectangle
for i = 1:size(cells, 1)
    j = 1;
    while j <= size(cells, 2)
        if cells(i, j)
            j_end = j;
            while j_end < size(cells, 2) && cells(i, j_end + 1)
                j_end = j_end + 1;
            end
            write_rect(fid, pg, x0 + (j - 1) * cell_size, y0 + (i - 1) * cell_size, (j_end - j + 1) * cell_size, cell_size);
            j = j_end + 1;
        else
            j = j + 1;
        end
    end
end
end

function write_rect(fid, pg, x, y, w, h)
% rectangle with top left corner (x, y) [mm on the board, y down] as PDF rectangle (points, y up)
fprintf(fid, '%s %s %s %s re\n', num((pg.b + x) * pg.k), num((pg.b + pg.H - y - h) * pg.k), num(w * pg.k), num(h * pg.k));
end

function s = num(v)
% number with 4 decimals (0.0001 pt = 0.035 micrometre), without trailing zeros
s = sprintf('%.4f', v);
s = regexprep(s, '\.?0+$', '');
if isempty(s) || strcmp(s, '-') || strcmp(s, '-0')
    s = '0';
end
end
