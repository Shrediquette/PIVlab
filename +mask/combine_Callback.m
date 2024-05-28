function combine_Callback (~,~,~)
handles=gui.gui_gethand;
current_mask_nr=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui.gui_retr('masks_in_frame');
if isempty(masks_in_frame)
	%masks_in_frame=cell(current_mask_nr,1);
	masks_in_frame=cell(1,current_mask_nr);
end
if numel(masks_in_frame)<current_mask_nr
	
else
	mask_positions=masks_in_frame{current_mask_nr};
	expected_image_size=gui.gui_retr('expected_image_size');
	if size(mask_positions,1) > 1 %combine only if there is something to combine
		mask.mask_combine(expected_image_size,mask_positions);
	end
end
