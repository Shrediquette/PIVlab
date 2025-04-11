function remove_bg_img (caller,~,~)
%if get(caller,'Value')==1
	%remove the background image. Needs to be done for ensemble correlation to work properly
	gui.put('bg_img_A',[]);
	gui.put('bg_img_B',[]);

%end

