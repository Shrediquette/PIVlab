function [contours, polys, ink] = cam_board_text(txt, font_size, origin)
% Text in the font of the ChArUco boards (preproc.cam_board_font, Archivo Black) as outlines in mm on
% the board (x to the right, y down), for the PDF (preproc.cam_board_pdf, exact curves) and the TIFF
% (preproc.cam_decorate_board, polygons). No kerning.
%   [contours, polys, ink] = preproc.cam_board_text(txt, font_size, origin)
% font_size: em size [mm]; origin: [x y] of the left end of the baseline [mm]
% contours: cell, one K x 5 matrix [type x1 y1 x2 y2] per contour (types as preproc.cam_board_font),
%           coordinates in mm, y down; fill rule even-odd
% polys:    the contours as closed polygons (N x 2, mm; curves in 8 straight pieces)
% ink:      [left right top bottom] of the outlines [mm] ([] for a text without ink)
F = preproc.cam_board_font();
contours = {};
x = 0; % pen position [em]
for c = double(txt)
    i = c - 31;
    if i < 1 || i > numel(F.advance) || isnan(F.advance(i))
        error('preproc:cam_board_text', 'Character ''%s'' is not in the board font.', char(c));
    end
    for k = 1:numel(F.contours{i})
        C = F.contours{i}{k};
        C(:, [2 4]) = origin(1) + (C(:, [2 4]) + x) * font_size;
        C(:, [3 5]) = origin(2) - C(:, [3 5]) * font_size; % y up -> y down
        contours{end + 1} = C; %#ok<AGROW>
    end
    x = x + F.advance(i);
end
if nargout > 1
    polys = cellfun(@flatten, contours, 'UniformOutput', false);
    pts = vertcat(polys{:});
    ink = [];
    if ~isempty(pts)
        ink = [min(pts(:, 1)), max(pts(:, 1)), min(pts(:, 2)), max(pts(:, 2))];
    end
end
end

function p = flatten(C)
n = 8; % straight pieces per curve
t = (1:n)' / n;
p = C(1, 4:5);
for r = 2:size(C, 1)
    if C(r, 1) == 1
        p(end + 1, :) = C(r, 4:5); %#ok<AGROW>
    else
        p = [p; (1 - t).^2 * p(end, :) + 2 * (1 - t) .* t * C(r, 2:3) + t.^2 * C(r, 4:5)]; %#ok<AGROW>
    end
end
end
