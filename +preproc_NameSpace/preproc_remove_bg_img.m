function preproc_remove_bg_img (~,~,~)
handles=gui_NameSpace.gui_gethand;
if get(handles.bg_subtract,'Value')==0
	%remove the background image. Needs to be done for ensemble correlation to work properly
	gui_NameSpace.gui_put('bg_img_A',[]);
	gui_NameSpace.gui_put('bg_img_B',[]);
end
