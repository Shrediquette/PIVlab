function update_roi_field(edit_handles, roi_handle, c)
vals = arrayfun(@(h) str2double(get(h,'String')), edit_handles);
[vals(1), vals(2), vals(3), vals(4)] = roi.snap_roi(vals(1), vals(2), vals(3), vals(4), c);
for i = 1:4
	set(edit_handles(i), 'String', num2str(vals(i)));
end
try
	set(roi_handle, 'Position', vals);
catch
end
