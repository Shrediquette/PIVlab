function mask_positions = uncovered_mask(owner)
%UNCOVERED_MASK PIVlab mask objects (masks_in_frame entries) of the part of the combined image no camera sees.
%   mask_positions = fov.uncovered_mask(owner)
%   owner  fov.owner_map (0 = no camera)
%   mask_positions  cell array as mask.update_mask_memory makes it (one row per polygon: type, position,
%                   colour, label, tag; keep the layout in step with that function), {} when every pixel is
%                   seen. Not mask.px_to_rois: it makes graphics objects and its reduce(0.005) would lose the
%                   one-pixel accuracy. Polygons with holes come as outer and
%                   inner boundary: PIVlab combines overlapping masks with the even-odd rule
%                   (mask.convert_masks_to_binary), so the hole stays free.
uncovered = owner == 0;
mask_positions = cell(0);
if ~any(uncovered(:))
    return
end
% outline at double resolution: it runs a quarter pixel outside the centres of the uncovered pixels, so the
% polygons (mask.convert_masks_to_binary: pixel centres inside) give exactly the uncovered pixels, also a strip
% of one pixel
fine = repelem(uncovered, 2, 2);
boundaries = bwboundaries(fine, 'holes');
colors = parula(7);
for k = 1:numel(boundaries)
    pos = (fliplr(boundaries{k}) + 0.5) / 2; % x, y in pixels of the combined image
    if size(pos, 1) > 8
        pos = reducepoly(pos, 1e-4); % only points on straight lines are removed
    end
    [~, tag] = fileparts(tempname);
    mask_positions(end + 1, :) = {'ROI_object_external', pos, colors(mod(k - 1, 6) + 1, :), '', tag}; %#ok<AGROW>
end
end
