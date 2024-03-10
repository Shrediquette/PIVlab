function calibrate_draw_line_Callback(~, ~, ~)
filepath=gui_NameSpace.gui_retr('filepath');
caliimg=gui_NameSpace.gui_retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
end
if size(filepath,1) >1 || numel(caliimg)>0 || gui_NameSpace.gui_retr('video_selection_done') == 1
	handles=gui_NameSpace.gui_gethand;
	gui_NameSpace.gui_toolsavailable(0)
	delete(findobj('tag', 'caliline'))
	roi = images.roi.Line;
	%roi.EdgeAlpha=0.75;
	roi.LabelVisible = 'on';
	roi.Tag = 'caliline';
	roi.Color = 'y';
	roi.StripeColor = 'g';
	roi.LineWidth = roi.LineWidth*2;
	Cali_coords = gui_NameSpace.gui_retr('pointscali');
	if ~isempty(Cali_coords)
		roi=drawline(gui_NameSpace.gui_retr('pivlab_axis'),'Position',Cali_coords);
		%roi.EdgeAlpha=0.75;
		roi.LabelVisible = 'on';
		roi.Tag = 'caliline';
		original_linewidth=roi.LineWidth;
		roi.LineWidth = original_linewidth*2;
		for rep=1:2 %bring users attention to already existing line
			roi.Color = 'g'; roi.StripeColor = 'y';
			pause(0.1)
			roi.Color = 'y'; roi.StripeColor = 'g';
			pause(0.1)
		end
		roi.Color = 'y';
		roi.StripeColor = 'g';
		roi.LineWidth = original_linewidth*2;
		pause(0.1)
	else
		axes(gui_NameSpace.gui_retr('pivlab_axis'))
		draw(roi);
	end
	addlistener(roi,'MovingROI',@calibrate_NameSpace.calibrate_Calibrationevents);
	addlistener(roi,'DeletingROI',@calibrate_NameSpace.calibrate_Calibrationevents);

	dummyevt.EventName = 'MovingROI';
	calibrate_NameSpace.calibrate_Calibrationevents(roi,dummyevt); %run the moving event once to update displayed length
	gui_NameSpace.gui_toolsavailable(1)
end
