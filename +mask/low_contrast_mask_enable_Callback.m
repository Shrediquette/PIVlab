function low_contrast_mask_enable_Callback(~,~,~)
handles=gui.gethand;
if get(handles.low_contrast_mask_enable,'Value')==0
	set(handles.low_contrast_mask_threshold_suggest,'enable','off')
	set(handles.mask_medfilt_enable_3,'enable','off');
	set(handles.median_size_3,'enable','off');
	set(handles.low_contrast_mask_threshold,'enable','off');
	set(handles.mask_imopen_imclose_enable_3,'enable','off');
	set(handles.imopen_imclose_size_3,'enable','off');
	set(handles.mask_imdilate_imerode_enable_3,'enable','off');
	set(handles.imopen_imclose_selection_3,'enable','off');
	set(handles.imdilate_imerode_size_3,'enable','off');
	set(handles.imdilate_imerode_selection_3,'enable','off');
	set(handles.mask_remove_enable_3,'enable','off');
	set(handles.remove_size_3,'enable','off');
	set(handles.mask_fill_enable_3,'enable','off');
else
	set(handles.low_contrast_mask_threshold_suggest,'enable','on')
	set(handles.mask_medfilt_enable_3,'enable','on');
	set(handles.median_size_3,'enable','on');
	set(handles.low_contrast_mask_threshold,'enable','on');
	set(handles.mask_imopen_imclose_enable_3,'enable','on');
	set(handles.imopen_imclose_size_3,'enable','on');
	set(handles.mask_imdilate_imerode_enable_3,'enable','on');
	set(handles.imopen_imclose_selection_3,'enable','on');
	set(handles.imdilate_imerode_size_3,'enable','on');
	set(handles.imdilate_imerode_selection_3,'enable','on');
	set(handles.mask_remove_enable_3,'enable','on');
	set(handles.remove_size_3,'enable','on');
	set(handles.mask_fill_enable_3,'enable','on');
end

