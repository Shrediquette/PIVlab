function roi = auto_roi(owner)
%AUTO_ROI Automatic region of interest of a combined image: a large rectangle inside the part the cameras see.
%   roi = fov.auto_roi(owner)
%   owner  fov.owner_map (0 = no camera)
%   roi    [x y width height] (PIVlab convention), 2 px inside the seen part (as stereo.auto_roi in stereo-PIV)
% The rectangle inside both views together, or inside the part of one camera when that is larger (views with a
% gap between them: no rectangle across the gap).
roi = [];
best = 0;
for k = 0:2
    if k == 0
        valid = owner > 0;
    else
        valid = owner == k;
    end
    if nnz(imerode(valid, true(5))) == 0
        continue
    end
    r = stereo.auto_roi(valid, 2);
    if r(3) * r(4) > best
        best = r(3) * r(4);
        roi = r;
    end
end
if isempty(roi)
    error('fov:auto_roi', 'The cameras see no part of the combined image.');
end
end
