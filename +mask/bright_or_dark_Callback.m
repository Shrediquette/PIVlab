function bright_or_dark_Callback(~,~,~)
handles=gui.gethand;
if get(handles.mask_bright_or_dark,'Value')==4 %custom script (coming soon)
	set(handles.binarize_enable,'Value',0)
	set(handles.binarize_enable_2,'Value',0)
	set(handles.low_contrast_mask_enable,'Value',0)
end
gui.update_dependent_controls(handles) %panel of the selected mask generator
if get(handles.mask_bright_or_dark,'Value')==4
	[file,path] = uigetfile('*.m');
end
