function [res, edited] = take_user_edits(res)
%TAKE_USER_EDITS Take over changes the user made in res.u, res.v, res.u_raw and res.v_raw.
%   res.u, res.v, ... are the velocities in the current units (res.units). All pivlab functions
%   compute with the same data in pixels per frame, stored in res.px (this keeps the results
%   identical to the PIVlab GUI). If the user changed values in res.u etc., e.g.
%       res.u(res.u > 10) = NaN;
%   these values are copied into res.px here. Only the values that were changed are copied, so
%   all other values stay exactly as computed.
%
%   edited.filtered  true if res.u or res.v were changed
%   edited.raw       true if res.u_raw or res.v_raw were changed
c = res.calibration;
p = res.px;
edited.filtered = false;
edited.raw = false;

if res.smoothed && ~isempty(p.u_smoothed)
    [p.u_smoothed, changed_u] = take_values(res.u, p.u_smoothed, c.calu, 'u');
    [p.v_smoothed, changed_v] = take_values(res.v, p.v_smoothed, c.calv, 'v');
else
    [p.u, changed_u] = take_values(res.u, p.u, c.calu, 'u');
    [p.v, changed_v] = take_values(res.v, p.v, c.calv, 'v');
end
edited.filtered = changed_u || changed_v;

[p.u_raw, changed_u] = take_values(res.u_raw, p.u_raw, c.calu, 'u_raw');
[p.v_raw, changed_v] = take_values(res.v_raw, p.v_raw, c.calv, 'v_raw');
edited.raw = changed_u || changed_v;

res.px = p;
end

function [pixel_data, changed_any] = take_values(user_data, pixel_data, factor, name)
% user_data: values in the current units, pixel_data: the same values in px/frame
current = pixel_data * factor;
if ~isequal(size(user_data), size(current))
    error('pivlab:editedResult:size', ...
        ['res.%s has the size %s, but the result has the size %s.' newline ...
        'You can change values in res.%s, but not add or remove vectors or frames ' ...
        '(use the Pairs option of pivlab.analyze or the Frames option of pivlab.temporal instead).'], ...
        name, mat2str(size(user_data)), mat2str(size(current)), name);
end
unchanged = (user_data == current) | (isnan(user_data) & isnan(current));
changed = ~unchanged;
changed_any = any(changed(:));
if changed_any
    pixel_data(changed) = user_data(changed) / factor;
end
end
