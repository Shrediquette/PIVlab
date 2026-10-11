function roi = auto_roi(valid, margin)
%AUTO_ROI Large axis-parallel rectangle inside the valid area (overlap of both cameras).
% valid: logical image, true where both cameras see the sheet. The valid area is first shrunk by margin pixels.
% The overlap of two camera views is convex, so a rectangle whose four edges are valid lies completely inside.
% Greedy: start with the bounding box and move the edge with the largest invalid fraction inwards.
% roi = [x y width height] (PIVlab convention: columns x..x+width, rows y..y+height).
if margin > 0
    valid = imerode(valid, true(2 * margin + 1));
end
rows = find(any(valid, 2));
cols = find(any(valid, 1));
if isempty(rows)
    error('stereo:auto_roi', 'No valid area left.');
end
r1 = rows(1); r2 = rows(end);
c1 = cols(1); c2 = cols(end);
while r2 > r1 && c2 > c1
    bad = [mean(~valid(r1, c1:c2)), mean(~valid(r2, c1:c2)), mean(~valid(r1:r2, c1)), mean(~valid(r1:r2, c2))];
    [worst, side] = max(bad);
    if worst == 0
        break
    end
    switch side
        case 1
            r1 = r1 + 1;
        case 2
            r2 = r2 - 1;
        case 3
            c1 = c1 + 1;
        case 4
            c2 = c2 - 1;
    end
end
roi = [c1, r1, c2 - c1, r2 - r1];
end
