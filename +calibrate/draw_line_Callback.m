function draw_line_Callback(~, ~, ~)
filepath=gui.retr('filepath');
caliimg=gui.retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
	gui.sliderdisp(gui.retr('pivlab_axis'))
end
if size(filepath,1) >1 || numel(caliimg)>0 || gui.retr('video_selection_done') == 1
	handles=gui.gethand;
	gui.toolsavailable(0)
	delete(findobj('tag', 'caliline'))
	regionOfInterest = images.roi.Line;
	%regionOfInterest.EdgeAlpha=0.75;
	regionOfInterest.LabelVisible = 'on';
	regionOfInterest.Tag = 'caliline';
	regionOfInterest.Color = 'y';
	regionOfInterest.StripeColor = 'g';
	regionOfInterest.LineWidth = regionOfInterest.LineWidth*2;
	Cali_coords = gui.retr('pointscali');
	if ~isempty(Cali_coords)
		regionOfInterest=drawline(gui.retr('pivlab_axis'),'Position',Cali_coords);
		%regionOfInterest.EdgeAlpha=0.75;
		regionOfInterest.LabelVisible = 'on';
		regionOfInterest.Tag = 'caliline';
		original_linewidth=regionOfInterest.LineWidth;
		regionOfInterest.LineWidth = original_linewidth*2;
		for rep=1:2 %bring users attention to already existing line
			regionOfInterest.Color = 'g'; regionOfInterest.StripeColor = 'y';
			pause(0.1)
			regionOfInterest.Color = 'y'; regionOfInterest.StripeColor = 'g';
			pause(0.1)
		end
		regionOfInterest.Color = 'y';
		regionOfInterest.StripeColor = 'g';
		regionOfInterest.LineWidth = original_linewidth*2;
		pause(0.1)
	else
		axes(gui.retr('pivlab_axis'))
		draw(regionOfInterest);
	end
	addlistener(regionOfInterest,'MovingROI',@calibrate.Calibrationevents);
	addlistener(regionOfInterest,'DeletingROI',@calibrate.Calibrationevents);

	dummyevt.EventName = 'MovingROI';
	calibrate.Calibrationevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
	gui.toolsavailable(1)
end

