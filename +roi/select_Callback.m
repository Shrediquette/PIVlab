function select_Callback(~, ~, ~)
filepath=gui.retr('filepath');
handles=gui.gethand;
if size(filepath,1) > 1 || gui.retr('video_selection_done') == 1
	delete(findobj('tag','warning'));
	gui.toolsavailable(0);
	toggler=gui.retr('toggler');
	selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
	filepath=gui.retr('filepath');
	delete(findobj('tag', 'RegionOfInterest'));
	regionOfInterest = images.roi.Rectangle;
	%roi.EdgeAlpha=0.75;
	regionOfInterest.FaceAlpha=0.05;
	regionOfInterest.LabelVisible = 'on';
	regionOfInterest.Tag = 'RegionOfInterest';
	regionOfInterest.Color = 'g';
	regionOfInterest.StripeColor = 'k';
	roirect = gui.retr('roirect');
	delete(findobj('tag', 'roiplot'));
	if ~isempty(roirect)
		regionOfInterest=drawrectangle(gui.retr('pivlab_axis'),'Position',roirect);
		%roi.EdgeAlpha=0.75;
		regionOfInterest.FaceAlpha=0.05;
		regionOfInterest.LabelVisible = 'on';
		regionOfInterest.Tag = 'RegionOfInterest';
		regionOfInterest.Color = 'g';
		regionOfInterest.StripeColor = 'k';
	else
		axes(gui.retr('pivlab_axis'))
		draw(regionOfInterest);
	end
	addlistener(regionOfInterest,'MovingROI',@roi.RegionOfInterestevents);
	addlistener(regionOfInterest,'DeletingROI',@roi.RegionOfInterestevents);
	dummyevt.EventName = 'MovingROI';
	roi.RegionOfInterestevents(regionOfInterest,dummyevt); %run the moving event once to update displayed length
	%put ('roirect',roi.Position);
	gui.toolsavailable(1);
end

