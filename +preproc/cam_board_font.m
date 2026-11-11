function F = cam_board_font()
% Glyph outlines of the font of the ChArUco board text (images/fonts/ArchivoBlack_glyphs.svg, made
% by images/fonts/ttf_to_svg_glyphs.m from Archivo Black, SIL Open Font License 1.1), cached.
% Characters 32 ... 126 (printable ASCII), index i = character code - 31:
%   F.advance(i)   advance width [em]
%   F.contours{i}  cell, one contour per cell: K x 5 [type x1 y1 x2 y2] in em, y up, baseline y = 0;
%                  type 0: start at (x2, y2), 1: line to (x2, y2), 2: quadratic curve with control
%                  point (x1, y1) to (x2, y2). Every contour is closed (ends at its start point).
% Fill rule even-odd (the glyphs have no overlapping contours).
persistent cache
if isempty(cache)
    txt = fileread(fullfile(fileparts(mfilename('fullpath')), '..', 'images', 'fonts', 'ArchivoBlack_glyphs.svg'));
    upem = str2double(regexp(txt, 'data-units-per-em="([^"]*)"', 'tokens', 'once'));
    glyphs = regexp(txt, '<path data-char="(\d+)" data-advance="([^"]*)"[^>]* d="([^"]*)"', 'tokens');
    F.advance = nan(1, 95);
    F.contours = cell(1, 95);
    for k = 1:numel(glyphs)
        i = str2double(glyphs{k}{1}) - 31;
        F.advance(i) = str2double(glyphs{k}{2}) / upem;
        cmds = regexp(glyphs{k}{3}, '([MLQZ])([^MLQZ]*)', 'tokens');
        contours = {};
        cur = zeros(0, 5);
        for j = 1:numel(cmds)
            v = sscanf(cmds{j}{2}, '%f')' / upem;
            switch cmds{j}{1}
                case 'M'
                    cur = [0 0 0 v];
                case 'L'
                    cur(end + 1, :) = [1 0 0 v]; %#ok<AGROW>
                case 'Q'
                    cur(end + 1, :) = [2 v]; %#ok<AGROW>
                case 'Z'
                    contours{end + 1} = cur; %#ok<AGROW>
            end
        end
        F.contours{i} = contours;
    end
    cache = F;
end
F = cache;
end
