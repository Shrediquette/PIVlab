function mask_binarize_enable_2_Callback(~,~,~)
handles=gui.gui_gethand;
if get(handles.binarize_enable_2,'Value')==0
	set(handles.mask_medfilt_enable_2,'enable','off');
	set(handles.median_size_2,'enable','off');
	set(handles.binarize_threshold_2,'enable','off');
	set(handles.mask_imopen_imclose_enable_2,'enable','off');
	set(handles.imopen_imclose_size_2,'enable','off');
	set(handles.mask_imdilate_imerode_enable_2,'enable','off');
	set(handles.imopen_imclose_selection_2,'enable','off');
	set(handles.imdilate_imerode_size_2,'enable','off');
	set(handles.imdilate_imerode_selection_2,'enable','off');
	set(handles.mask_remove_enable_2,'enable','off');
	set(handles.remove_size_2,'enable','off');
	set(handles.mask_fill_enable_2,'enable','off');
else
	set(handles.mask_medfilt_enable_2,'enable','on');
	set(handles.median_size_2,'enable','on');
	set(handles.binarize_threshold_2,'enable','on');
	set(handles.mask_imopen_imclose_enable_2,'enable','on');
	set(handles.imopen_imclose_size_2,'enable','on');
	set(handles.mask_imdilate_imerode_enable_2,'enable','on');
	set(handles.imopen_imclose_selection_2,'enable','on');
	set(handles.imdilate_imerode_size_2,'enable','on');
	set(handles.imdilate_imerode_selection_2,'enable','on');
	set(handles.mask_remove_enable_2,'enable','on');
	set(handles.remove_size_2,'enable','on');
	set(handles.mask_fill_enable_2,'enable','on');
end

