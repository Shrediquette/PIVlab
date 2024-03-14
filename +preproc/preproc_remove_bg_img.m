function preproc_remove_bg_img (~,~,~)
handles=gui.gui_gethand;
if get(handles.bg_subtract,'Value')==0
	%remove the background image. Needs to be done for ensemble correlation to work properly
	gui.gui_put('bg_img_A',[]);
	gui.gui_put('bg_img_B',[]);
end

