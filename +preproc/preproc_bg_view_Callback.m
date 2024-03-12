function preproc_bg_view_Callback (~,~) %displays background in GUI
handles=gui.gui_gethand;
bg_toggle=gui.gui_retr('bg_toggle');
if isempty(bg_toggle)
	bg_toggle=0;
elseif bg_toggle==0
	bg_toggle=1;
elseif bg_toggle==1
	bg_toggle=0;
end
gui.gui_put('bg_toggle',bg_toggle)
if get(handles.bg_subtract,'Value')==1
	bg_img_A = gui.gui_retr('bg_img_A');
	bg_img_B = gui.gui_retr('bg_img_B');
	sequencer=gui.gui_retr('sequencer');%Timeresolved or pairwise 0=timeres.; 1=pairwise
	if sequencer ~= 2 % bg subtraction only makes sense with time-resolved and pairwise sequencing style, not with reference style.
		if isempty(bg_img_A) || isempty(bg_img_B)
			if gui.gui_retr('video_selection_done') == 0 && gui.gui_retr('parallel')==1 % this is not nice, duplicated functions, one for parallel and one for video....
				preproc.preproc_generate_BG_img_parallel
			else
				preproc.preproc_generate_BG_img
			end

			bg_img_A = gui.gui_retr('bg_img_A');
			bg_img_B = gui.gui_retr('bg_img_B');
		end
		%display it (needs to be toggable....)
		pivlab_axis=gui.gui_retr('pivlab_axis');
		if bg_toggle==0
			image(imadjust(bg_img_A), 'parent',pivlab_axis, 'cdatamapping', 'scaled');
		elseif bg_toggle==1
			image(imadjust(bg_img_B), 'parent',pivlab_axis, 'cdatamapping', 'scaled');
		end
		colormap('gray');
		axis image;
		set(gca,'ytick',[])
		set(gca,'xtick',[])
	end
end

