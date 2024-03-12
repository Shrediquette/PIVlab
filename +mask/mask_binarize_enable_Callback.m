function mask_binarize_enable_Callback(~,~,~)
handles=gui.gui_gethand;
if get(handles.binarize_enable,'Value')==0
	set(handles.mask_medfilt_enable,'enable','off');
	set(handles.median_size,'enable','off');
	set(handles.binarize_threshold,'enable','off');
	set(handles.mask_imopen_imclose_enable,'enable','off');
	set(handles.imopen_imclose_size,'enable','off');
	set(handles.mask_imdilate_imerode_enable,'enable','off');
	set(handles.imopen_imclose_selection,'enable','off');
	set(handles.imdilate_imerode_size,'enable','off');
	set(handles.imdilate_imerode_selection,'enable','off');
	set(handles.mask_remove_enable,'enable','off');
	set(handles.remove_size,'enable','off');
	set(handles.mask_fill_enable,'enable','off');
else
	set(handles.mask_medfilt_enable,'enable','on');
	set(handles.median_size,'enable','on');
	set(handles.binarize_threshold,'enable','on');
	set(handles.mask_imopen_imclose_enable,'enable','on');
	set(handles.imopen_imclose_size,'enable','on');
	set(handles.mask_imdilate_imerode_enable,'enable','on');
	set(handles.imopen_imclose_selection,'enable','on');
	set(handles.imdilate_imerode_size,'enable','on');
	set(handles.imdilate_imerode_selection,'enable','on');
	set(handles.mask_remove_enable,'enable','on');
	set(handles.remove_size,'enable','on');
	set(handles.mask_fill_enable,'enable','on');
end

