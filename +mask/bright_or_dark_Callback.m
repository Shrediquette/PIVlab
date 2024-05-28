function bright_or_dark_Callback(~,~,~)
handles=gui.gui_gethand;
if get(handles.mask_bright_or_dark,'Value')==1
	set (handles.uipanel25_3,'Visible','on')
	set (handles.uipanel25_5,'Visible','off')
	set (handles.uipanel25_7,'Visible','off')
	mask.mask_binarize_enable_Callback
elseif get(handles.mask_bright_or_dark,'Value')==2
	set (handles.uipanel25_3,'Visible','off')
	set (handles.uipanel25_5,'Visible','on')
	set (handles.uipanel25_7,'Visible','off')
	mask.mask_binarize_enable_2_Callback
elseif get(handles.mask_bright_or_dark,'Value')==3
	set (handles.uipanel25_3,'Visible','off')
	set (handles.uipanel25_5,'Visible','off')
	set (handles.uipanel25_7,'Visible','on')
	mask.mask_low_contrast_mask_enable_Callback
end

