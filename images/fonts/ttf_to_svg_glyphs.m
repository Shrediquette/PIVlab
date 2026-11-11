function ttf_to_svg_glyphs(ttf_file, svg_file, chars)
% One-time tool: glyph outlines of a TrueType font -> SVG file with one path per character, for the
% text on the ChArUco boards (preproc.cam_board_font, preproc.cam_board_text).
%   ttf_to_svg_glyphs('ArchivoBlack-Regular.ttf', 'ArchivoBlack_glyphs.svg')
% The outlines are kept exactly: lines and quadratic curves (SVG commands M, L, Q, Z), in font units
% with y up as in the font. Per glyph: character code (data-char) and advance width (data-advance).
% No kerning. chars: characters to extract, default printable ASCII (32 ... 126).
% The boards are filled with fill rule even-odd (the white layer of the PDF is the complement of the
% black one), the font with non-zero winding: every glyph is checked for overlapping contours, for
% which the two rules differ (a warning lists them).
% Source of ArchivoBlack_glyphs.svg: ArchivoBlack-Regular.ttf from https://github.com/google/fonts
% (ofl/archivoblack), SIL Open Font License 1.1 (OFL.txt in this folder).
if nargin < 3
    chars = char(32:126);
end
fid = fopen(ttf_file, 'r');
if fid < 0
    error('Could not read %s', ttf_file);
end
b = double(fread(fid, inf, 'uint8=>uint8'))';
fclose(fid);

% table directory
tables = struct();
for k = 0:u16(4) - 1
    rec = 12 + 16 * k;
    tables.(matlab.lang.makeValidName(char(b(rec + 1:rec + 4)))) = u32(rec + 8);
end
upem = u16(tables.head + 18);
loc_format = s16(tables.head + 50);
n_glyphs = u16(tables.maxp + 4);
ascender = s16(tables.hhea + 4);
descender = s16(tables.hhea + 6);
n_hmetrics = u16(tables.hhea + 34);
loca = zeros(1, n_glyphs + 1);
for g = 0:n_glyphs
    if loc_format == 0
        loca(g + 1) = 2 * u16(tables.loca + 2 * g);
    else
        loca(g + 1) = u32(tables.loca + 4 * g);
    end
end

% character map: format 4 subtable of platform 3 (Windows), encoding 1 (Unicode BMP)
cmap = tables.cmap;
sub = [];
for k = 0:u16(cmap + 2) - 1
    if u16(cmap + 4 + 8 * k) == 3 && u16(cmap + 6 + 8 * k) == 1 && u16(cmap + u32(cmap + 8 + 8 * k)) == 4
        sub = cmap + u32(cmap + 8 + 8 * k);
    end
end
if isempty(sub)
    error('No Unicode cmap (format 4) in %s', ttf_file);
end

fid = fopen(svg_file, 'w');
fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid, ['<!-- Glyph outlines of %s (font units, y up), made by images/fonts/ttf_to_svg_glyphs.m.\n' ...
    '     Archivo Black: Copyright 2017 The Archivo Black Project Authors (https://github.com/Omnibus-Type/ArchivoBlack),\n' ...
    '     SIL Open Font License 1.1, see OFL.txt in this folder. -->\n'], ttf_name(ttf_file));
fprintf(fid, '<svg xmlns="http://www.w3.org/2000/svg" data-units-per-em="%d" data-ascender="%d" data-descender="%d" viewBox="0 %d %d %d">\n', ...
    upem, ascender, descender, -ascender, upem, ascender - descender);
overlapping = '';
for c = double(chars)
    g = glyph_id(c);
    [x, y, on, ends] = glyph_points(g);
    d = '';
    contours = {};
    starts = [0, ends(1:end - 1) + 1] + 1; % 1-based
    for k = 1:numel(ends)
        idx = starts(k):ends(k) + 1;
        [dk, poly] = contour_path(x(idx), y(idx), on(idx));
        d = [d dk]; %#ok<AGROW>
        contours{end + 1} = poly; %#ok<AGROW>
    end
    if ~even_odd_safe(contours)
        overlapping = [overlapping char(c)]; %#ok<AGROW>
    end
    fprintf(fid, '<path data-char="%d" data-advance="%d" transform="scale(1,-1)" d="%s"/>\n', c, advance(g), d);
end
fprintf(fid, '</svg>\n');
fclose(fid);
if ~isempty(overlapping)
    warning('Glyphs with overlapping contours (even-odd differs from non-zero): %s', overlapping);
end

    function v = u16(o) % o: 0-based offset
        v = b(o + 1) * 256 + b(o + 2);
    end
    function v = s16(o)
        v = u16(o);
        v = v - 65536 * (v >= 32768);
    end
    function v = u32(o)
        v = u16(o) * 65536 + u16(o + 2);
    end

    function g = glyph_id(c)
        seg_x2 = u16(sub + 6);
        end_codes = sub + 14;
        start_codes = end_codes + seg_x2 + 2;
        deltas = start_codes + seg_x2;
        range_offsets = deltas + seg_x2;
        g = 0;
        for i = 0:seg_x2 / 2 - 1
            if u16(end_codes + 2 * i) >= c
                start = u16(start_codes + 2 * i);
                if start <= c
                    ro = u16(range_offsets + 2 * i);
                    if ro == 0
                        g = mod(c + s16(deltas + 2 * i), 65536);
                    else
                        g = u16(range_offsets + 2 * i + ro + 2 * (c - start));
                        if g ~= 0
                            g = mod(g + s16(deltas + 2 * i), 65536);
                        end
                    end
                end
                return
            end
        end
    end

    function a = advance(g)
        a = u16(tables.hmtx + 4 * min(g, n_hmetrics - 1));
    end

    function [x, y, on, ends] = glyph_points(g)
        % points of all contours (end index of every contour in ends, 0-based); composite glyphs
        % are assembled from their components
        x = [];
        y = [];
        on = false(1, 0);
        ends = [];
        o = tables.glyf + loca(g + 1);
        if loca(g + 2) == loca(g + 1)
            return % no outline (space)
        end
        nc = s16(o);
        if nc >= 0
            ends = arrayfun(@(i) u16(o + 10 + 2 * i), 0:nc - 1);
            np = ends(end) + 1;
            p = o + 12 + 2 * nc + u16(o + 10 + 2 * nc); % after the instructions
            flags = zeros(1, np);
            i = 1;
            while i <= np
                f = b(p + 1);
                p = p + 1;
                flags(i) = f;
                i = i + 1;
                if bitand(f, 8) % repeat
                    r = b(p + 1);
                    p = p + 1;
                    flags(i:i + r - 1) = f;
                    i = i + r;
                end
            end
            [x, p] = coordinates(flags, 2, 16, p);
            [y, ~] = coordinates(flags, 4, 32, p);
            on = bitand(flags, 1) > 0;
        else
            p = o + 10;
            more = true;
            while more
                flags = u16(p);
                [cx, cy, con, cends] = glyph_points(u16(p + 2));
                p = p + 4;
                if bitand(flags, 1) % 16 bit arguments
                    dx = s16(p);
                    dy = s16(p + 2);
                    p = p + 4;
                else
                    dx = b(p + 1) - 256 * (b(p + 1) >= 128);
                    dy = b(p + 2) - 256 * (b(p + 2) >= 128);
                    p = p + 2;
                end
                if ~bitand(flags, 2)
                    error('Glyph %d: component placed by point numbers (not supported)', g);
                end
                T = eye(2);
                if bitand(flags, 8)
                    T = eye(2) * s16(p) / 16384;
                    p = p + 2;
                elseif bitand(flags, 64)
                    T = diag([s16(p) s16(p + 2)] / 16384);
                    p = p + 4;
                elseif bitand(flags, 128)
                    T = [s16(p) s16(p + 4); s16(p + 2) s16(p + 6)] / 16384;
                    p = p + 8;
                end
                xy = T * [cx; cy];
                ends = [ends, cends + numel(x)]; %#ok<AGROW>
                x = [x, xy(1, :) + dx]; %#ok<AGROW>
                y = [y, xy(2, :) + dy]; %#ok<AGROW>
                on = [on, con]; %#ok<AGROW>
                more = bitand(flags, 32) > 0;
            end
        end
    end

    function [v, p] = coordinates(flags, short_bit, same_bit, p)
        v = zeros(1, numel(flags));
        val = 0;
        for i = 1:numel(flags)
            f = flags(i);
            if bitand(f, short_bit)
                dv = b(p + 1);
                p = p + 1;
                if ~bitand(f, same_bit)
                    dv = -dv;
                end
            elseif bitand(f, same_bit)
                dv = 0;
            else
                dv = s16(p);
                p = p + 2;
            end
            val = val + dv;
            v(i) = val;
        end
    end
end

function [d, poly] = contour_path(x, y, on)
% TrueType contour (on- and off-curve points; between two off-curve points lies an implied on-curve
% point) as SVG path data M, L, Q, Z; poly: flattened outline for the overlap check
if ~any(on)
    x = [(x(end) + x(1)) / 2, x];
    y = [(y(end) + y(1)) / 2, y];
    on = [true, on];
end
k0 = find(on, 1);
order = [k0:numel(x), 1:k0 - 1];
x = [x(order), x(k0)];
y = [y(order), y(k0)];
on = [on(order), true];
d = sprintf('M%g %g', x(1), y(1));
poly = [x(1), y(1)];
i = 2;
while i <= numel(x)
    if on(i)
        d = [d sprintf('L%g %g', x(i), y(i))]; %#ok<AGROW>
        poly(end + 1, :) = [x(i), y(i)]; %#ok<AGROW>
        i = i + 1;
    else
        if on(i + 1)
            e = [x(i + 1), y(i + 1)];
            next = i + 2;
        else
            e = [(x(i) + x(i + 1)) / 2, (y(i) + y(i + 1)) / 2];
            next = i + 1;
        end
        d = [d sprintf('Q%g %g %g %g', x(i), y(i), e(1), e(2))]; %#ok<AGROW>
        t = (1:8)' / 8;
        p0 = poly(end, :);
        poly = [poly; (1 - t).^2 * p0 + 2 * (1 - t) .* t * [x(i), y(i)] + t.^2 * e]; %#ok<AGROW>
        i = next;
    end
end
d = [d 'Z'];
end

function ok = even_odd_safe(contours)
% true: fill rule even-odd gives the same as non-zero: contours do not cross, and of two nested
% contours the inner one runs the other way round (a hole)
ok = true;
warning('off', 'MATLAB:polyshape:repairedBySimplify');
cleanup = onCleanup(@() warning('on', 'MATLAB:polyshape:repairedBySimplify'));
for i = 1:numel(contours)
    for j = i + 1:numel(contours)
        pi_ = polyshape(contours{i});
        pj = polyshape(contours{j});
        a = area(intersect(pi_, pj));
        if a < 1e-6 * min(area(pi_), area(pj))
            continue % apart
        end
        nested = abs(a - min(area(pi_), area(pj))) < 1e-3 * min(area(pi_), area(pj));
        if ~nested || sign(signed_area(contours{i})) == sign(signed_area(contours{j}))
            ok = false;
            return
        end
    end
end
end

function a = signed_area(p)
% shoelace formula: positive for a counter-clockwise contour (y up)
a = sum(p(:, 1) .* circshift(p(:, 2), -1) - circshift(p(:, 1), -1) .* p(:, 2)) / 2;
end

function name = ttf_name(file)
[~, n, e] = fileparts(file);
name = [n e];
end
