function calibrate_cal_actual_Callback(~, ~, ~) %executed when calibration panel is made visible
gui.gui_switchui('multip07')
pointscali=gui.gui_retr('pointscali');

if numel(pointscali)>0
	caliimg=gui.gui_retr('caliimg');
	if numel(caliimg)>0
		pivlab_axis=gui.gui_retr('pivlab_axis');
		image(caliimg, 'parent',pivlab_axis, 'cdatamapping', 'scaled');
		colormap('gray');
		axis image;
		set(gca,'ytick',[])
		set(gca,'xtick',[])
	else
		gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))
	end

	calibrate.calibrate_draw_line_Callback

	calibrate.calibrate_Update_Offset_Display;
	handles=gui.gui_gethand;
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','on')
else %no calibration performed yet
	handles=gui.gui_gethand;
	if gui.gui_retr('video_selection_done') == 1 %video file loaded
		%enter a guess for the time step, based on video file frame rate.
		video_reader_object = gui.gui_retr('video_reader_object');
		video_frame_selection=gui.gui_retr('video_frame_selection');
		skip = video_frame_selection(2) - video_frame_selection(1);
		delta_t = 1/(video_reader_object.FrameRate / skip)*1000;

		set(handles.time_inp,'String',num2str(delta_t))
	end
	set(findobj(handles.uipanel_offsets,'Type','uicontrol'),'Enable','off')
end

