function remove_bg_img (~,~,~)
handles=gui.gethand;
if get(handles.bg_subtract,'Value')==0
	%remove the background image. Needs to be done for ensemble correlation to work properly
	gui.put('bg_img_A',[]);
	gui.put('bg_img_B',[]);
end

